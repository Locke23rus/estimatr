require 'spec_helper'

describe SessionsController do

  describe 'DELETE destroy' do
    before do
      session[:user_id] = 123
      delete :destroy
    end

    it 'deletes the session[:user_id]' do
      session[:user_id].should be_blank
    end

    it 'redirects to the root path' do
      response.should redirect_to(root_path)
    end

    it { should set_the_flash }
  end

end
