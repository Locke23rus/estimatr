require 'bundler/setup'

Bundler.require(:default, ENV['RACK_ENV'].to_sym)
require 'sinatra/json'
require 'sinatra/reloader' if development?

configure do
  enable :sessions

  User = Struct.new(:id, :login)
  CARDS = %w(zero 1 2 3 4 5 8 13 21 infinity)
end

configure :development do
  Pusher.app_id = '17070'
  Pusoer.key    = '3cf652f57ba3c09034ef'
  Pusher.secret = '2906b9a87aab6cdaadef'

  REDIS = Redis.new
end

configure :production do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

def current_user
  return if session[:login].nil? || session[:id].nil?

  @current_user ||= User.new(session[:id], session[:login])
end

def login(login)
  session[:id] = create_token
  session[:login] = login
  @current_user = User.new(session[:id], login)
end

def logout
  session[:id] = session[:login] = nil
  @current_user = nil
end

def authorize
  redirect to('/') if current_user.nil?
end

def create_token
  rand(36**8).to_s(36)
end

def find_room(room)
  REDIS.get("rooms:#{room}:owner")
end

get '/' do
  if current_user
    redirect to('/rooms/new')
  else
    erb :index
  end
end

post '/login' do
  if params[:login] =~ /^\w{3,}$/
    login params[:login]
    redirect to('/rooms/new')
  else
    flash[:error] = 'You must enter a valid login.'
    redirect to('/')
  end
end

get '/logout' do
  logout
  redirect to('/')
end

before('/rooms/*') { authorize }

get '/rooms/new' do
  erb :'rooms/new'
end

post '/rooms/new' do
  token = create_token
  token = create_token while find_room(token)
  REDIS.set "rooms:#{token}:owner", current_user.id
  redirect to("/rooms/#{token}")
end

before '/rooms/:room*' do
  @room_owner = @room = find_room(params[:room])
  @room = params[:room] if @room_owner
end

get '/rooms/:room' do
  if @room
    @user = current_user
    @owner = @room_owner == current_user.id
    erb :'rooms/show', locals: { cards: CARDS }
  else
    flash[:error] = "Room doesn't exist."
    redirect to('/rooms/new')
  end
end

get '/rooms/:room/votes' do
  if @room
    json REDIS.hkeys("rooms:#{@room}:votes")
  else
    halt 404
  end
end

post '/rooms/:room/vote' do
  if @room && params[:card] && CARDS.include?(params[:card])
    REDIS.hset "rooms:#{@room}:votes", current_user.login, params[:card]
    Pusher["presence-#{@room}"].trigger('voted', { id: current_user.id })
  else
    halt 404
  end
end

post '/rooms/:room/reset' do
  if @room
    Pusher["presence-#{@room}"].trigger('reset-cards', {})
    REDIS.del "rooms:#{@room}:votes"
  else
    halt 404
  end
end

post '/rooms/:room/open' do
  if @room
    Pusher["presence-#{@room}"].trigger('open-cards', REDIS.hgetall("rooms:#{@room}:votes"))
  else
    halt 404
  end
end

post '/pusher/auth' do
  if current_user
    response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
      :user_id => current_user.id, # => required
      :user_info => { :login => current_user.login }
    })
    json response
  else
    halt 403, "Not authorized"
  end
end

