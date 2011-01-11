class MicropostsController < ApplicationController
  before_filter :authenticate
  
  def post
    @oauth_key = OauthKey.where(:user_id=>current_user.id, :target=>"Sina Weibo").first
    @consumer = OAuth::Consumer.new( "1496205680","065485c1a08e2e18970bd14becaf2aee", {
          :site=>"http://api.t.sina.com.cn",
          :scheme => :header,
          :http_method => :post,
          :request_token_path => "/oauth/request_token",
          :access_token_path  => "/oauth/access_token",
          :authorize_path  => "/oauth/authorize"
        })
    @access_token = OAuth::AccessToken.new( @consumer, @oauth_key.token, @oauth_key.secret )
    @response = @access_token.post('/statuses/update.json', {:status => params[:content]})

    if @response.code == '200'
      redirect_to root_path, :flash => { :success => "Message posted!" }
    else
      redirect_to root_path, :flash => {:success => @response.message}
    end
  end  
end
