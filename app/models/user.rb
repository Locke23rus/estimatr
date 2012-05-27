class User < ActiveRecord::Base

  validates :uid, :presence => true, :uniqueness => true

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.nickname = auth['info']['nickname']
      user.name = auth['info']['name']
      user.image = auth['info']['image']
    end
  end

end
