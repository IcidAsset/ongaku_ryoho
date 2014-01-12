class UsersController < ApplicationController
  before_filter :require_login, only: [:edit, :update, :destroy]
  layout 'pages'

  def new
    @user = User.new
  end


  def create
    @user = User.new(params[:user])

    if User.count < 1
      if @user.save
        auto_login(@user, true)
        redirect_to root_url
      else
        render :new
      end

    else
      @user_capacity_error = "The user capacity for the alpha version has been reached"
      render :new

    end
  end


  def edit
    @user = current_user
  end


  def update
    @user = current_user

    paru = params[:user]
    old_password = paru[:old_password]

    # check old password, stop if invalid
    unless User.authenticate(@user.email, old_password)
      flash.now[:error] = "Old password was invalid"

      return render :edit
    end

    # attributes object
    email_attr = { email: paru[:email] }

    # only update e-mail
    if paru[:password].blank?
      if @user.update_attributes(email_attr)
        flash.now[:success] = "E-mail updated"
      end

    # update e-mail and password
    else
      password = paru[:password]
      password_confirmation = paru[:password_confirmation]

      if password === password_confirmation
        attributes = email_attr.merge({
          password: password,
          password_confirmation: password_confirmation
        })

        if @user.update_attributes(attributes)
          flash.now[:success] = "Account settings updated"
        end
      else
        flash.now[:error] = "Password doesn't match confirmation"
      end

    end

    # render page
    render :edit
  end


  def destroy
    current_user.try(:destroy)
    logout
  end

end
