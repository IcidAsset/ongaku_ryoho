class PagesController < ApplicationController
  before_filter :require_login, only: [:settings, :account]

  def about
    redirect_to root_url if logged_in?
  end
end
