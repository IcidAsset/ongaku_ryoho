class UsersController < ApplicationController
  layout 'pages'

  def new
    @user = User.new
  end


  def create
    @user = User.new(params[:user])

    if @user.save
      auto_login(@user)
      redirect_to root_url
    else
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

    unless User.authenticate(@user.email, old_password)
      flash.now[:error] = "Old password was invalid"

      return render :edit
    end

    email_attr = { email: paru[:email] }

    if paru[:password].blank?
      if @user.update_attributes(email_attr)
        flash.now[:success] = "E-mail updated"
      end
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

    render :edit
  end

end
