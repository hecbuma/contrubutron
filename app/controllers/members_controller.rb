class MembersController < ApplicationController
  def show
    @organization = Organization.where(id: params[:organization]).try(:first) || current_user.organizations.where(aasm_state: 'completed').try(:first) 
    @member = Member.find(params[:id])
  end
end
