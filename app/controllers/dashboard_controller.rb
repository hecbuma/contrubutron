class DashboardController < ApplicationController
  before_filter :authenticate!

  def index

    @organization = Organization.where(id: params[:organization]).try(:first) || current_user.organizations.where(aasm_state: 'completed').try(:first)
    if @organization
      params[:organization] = @organization.id
      if current_user.organizations.where("aasm_state like 'fetching'").size > 0 && !@organization.fetching?
        flash[:alert] = "You can only process one organization at the time."
      elsif @organization.created?
        @organization.move_to_queue(session[:user_token], current_user)
      end
    end

    flash[:info] = "Start by selecting one of your organization." unless current_user.organizations.where("aasm_state like 'completed'").any?
  end

  def show
  end


end
