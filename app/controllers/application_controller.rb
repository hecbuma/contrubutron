class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  before_filter :get_organizations


  private

  def current_user
    @current_user ||= User.where(:id => session[:user_id]).first
  end

  def authenticate!
    unless current_user
      flash[:notice] = 'You have to be logged in'
      redirect_to root_url
    end
  end

  def get_organizations
    organizations = GithubService.new(session[:user_token]).get_organizations
    organizations.each do |organization|
      new_organization = Organization.create_with(avatar: organization['avatar_url']).find_or_initialize_by(name: organization['login'])
      new_record = new_organization.new_record?
      new_organization.save if new_record
      current_user.organizations << new_organization unless current_user.organization_ids.include?(new_organization.id)
      if new_record || new_organization.members.empty?
        members = get_members organization
        members.each do |member|
          new_member = Member.create_with(avatar: member['avatar_url'], profile: member['html_url']).find_or_initialize_by(name: member['login'])
          is_member_new = new_member.new_record?
          new_member.save if is_member_new
          new_organization.members << new_member unless new_organization.member_ids.include?(new_member.id)
        end
      end
    end
    @organizations = current_user.organizations
  end

  def get_members(org)
    GithubService.new(session[:user_token]).get_members(org)
  end

end
