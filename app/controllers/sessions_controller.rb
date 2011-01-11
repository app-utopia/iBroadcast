class SessionsController < ApplicationController

  def new
    @title = "Sign in"
  end
  
  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else
      sign_in user
      redirect_back_or user
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

  def save_oauth_token
    @access_token = session[:request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
    @key = OauthKey.new
    @key.user_id = current_user.id
    @key.target = "Sina Weibo"
    @key.token = @access_token.token
    @key.secret = @access_token.secret
    @key.save
    redirect_to root_path
  end
end
