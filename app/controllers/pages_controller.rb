class PagesController < ApplicationController
  before_filter :authenticate_user!, only: [:settings, :update_settings, :account]
  before_filter :redirect_if_logged_in, only: [:about]
  helper FormHelpers

  def about
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
