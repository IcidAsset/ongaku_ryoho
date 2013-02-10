class PagesController < ApplicationController
  before_filter :require_login, only: [:settings, :account]
  helper FormHelpers

  def about
    redirect_to root_url if logged_in?
  end


  def update_settings
    settings = params["user"]["settings"]

    if current_user.update_attributes(settings: settings)
      flash.now[:success] = "Updated settings"
    else
      flash.now[:error] = "Could not save settings"
    end

    render "pages/settings"
  end

end
