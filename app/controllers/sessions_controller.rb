class SessionsController < ApplicationController
  before_filter :redirect_if_logged_in, only: [:new]
  layout 'pages'

  def new
  end


  def create
    user = login(
      params[:email].try(:downcase),
      params[:password],
      true
    )

    if user
      redirect_back_or_to root_url, :notice => "Logged in!"
    else
      flash.now[:error] = "Email or password was invalid"
      render "sessions/new"
    end
  end


  def destroy
    logout
    redirect_to root_url, :notice => "Logged out!"
  end

end
