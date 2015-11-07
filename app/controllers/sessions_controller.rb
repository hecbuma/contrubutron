class SessionsController < ApplicationController
  before_filter :avoid_logged_in_user_to_sign_in, :except => :destroy


  def create
    auth = request.env["omniauth.auth"]
    user = User.with_omniauth(auth)
    session[:user_id] = user.id
    session[:user_token] = auth['credentials']['token']
    redirect_to dashboard_index_path, notice: 'Signed in!'
  end

  def destroy
    session[:user_id] = nil
    session[:user_token] = nil
    redirect_to root_path, notice: 'Signed out!'
  end

  private
  def avoid_logged_in_user_to_sign_in
    if current_user
      redirect_to dashboard_index_path, alert: "You have already logged in"
    end
  end

end
