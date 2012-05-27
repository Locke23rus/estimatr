require 'spec_helper'

describe User do

  describe '.create_with_omniauth!' do
    let(:auth) do
      {
        uid: rand(1000),
        info: {
          nickname: Faker::Internet.user_name,
          name: Faker::Name.name,
          image: Faker::Internet.http_url
        }
      }
    end

    subject { User.create_with_omniauth!(auth) }

    it 'creates a new user with given uid' do
      subject.uid.should == auth[:uid]
    end

    it 'creates a new user with given nickname' do
      subject.nickname.should == auth[:info][:nickname]
    end

    it 'creates a new user with given name' do
      subject.name.should == auth[:info][:name]
    end

    it 'creates a new user with given avatar' do
      subject.avatar_url.should == auth[:info][:image]
    end
  end

end
