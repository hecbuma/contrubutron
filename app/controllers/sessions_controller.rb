class SessionsController < ApplicationController
  before_filter :avoid_logged_in_user_to_sign_in, :except => [:destroy, :edit, :update]
  skip_before_filter :get_organizations, :only => [:create, :destroy]


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

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user == current_user
      if @user.update_attributes user_params
        message = {notice: 'Everything is cool, info updated.'}
      else
        message = {alert: 'looks like something went wrong.'}
      end
      redirect_to :back, message
    else
      redirect_to root_path, alert: "you don't have permission to edit that data"
    end
  end

  private
  def avoid_logged_in_user_to_sign_in
    if current_user
      redirect_to dashboard_index_path, alert: "You have already logged in"
    end
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

end
