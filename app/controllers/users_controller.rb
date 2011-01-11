class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy
  
  def index
    @users = User.paginate(:page => params[:page])
    @title = "All users"
  end
  
  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  def new
    @user  = User.new
    @title = "Sign up"
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      @consumer=OAuth::Consumer.new( "1496205680","065485c1a08e2e18970bd14becaf2aee", {
          :site=>"http://api.t.sina.com.cn",
          :scheme => :header,
          :http_method => :post,
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path  => "/oauth/authorize"

      })

      @request_token = @consumer.get_request_token
      session[:request_token] = @request_token
      redirect_to @request_token.authorize_url(:oauth_callback => "http://localhost:3000/sessions/save_oauth_token?id=#{@user.id}")
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end
  
  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, :flash => { :success => "Profile updated." }
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, :flash => { :success => "User destroyed." }
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      @user = User.find(params[:id])
      redirect_to(root_path) if !current_user.admin? || current_user?(@user)
    end
end
