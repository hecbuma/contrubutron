class SiteController < ApplicationController
  layout 'landing'
  skip_before_filter :get_organizations

  def index
  end
end
