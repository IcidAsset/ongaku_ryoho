class UsersController < ApplicationController
  layout 'pages'

  # GET 'sign-up'
  def new
    @user = User.new
  end

  # POST 'users'
  def create
    @user = User.new(params[:user])

    if @user.save
      auto_login(@user)
      redirect_to root_url
    else
      render :new
    end
  end
end
