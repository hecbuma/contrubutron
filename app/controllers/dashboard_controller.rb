class DashboardController < ApplicationController
  before_filter :authenticate!

  before_filter :get_organizations

  def index
    flash[:info] = "Start by selecting one of your organization." unless @organization_default
  end

  def show
  end

  private

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
            new_member = Member.create_with(avatar: member['avatar_url'], profile: member['received_events_url']).find_or_initialize_by(name: member['login'])
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
