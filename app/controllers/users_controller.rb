class UsersController < Devise::RegistrationsController
  before_filter :redirect_if_logged_in, only: [:new, :create]
  layout 'pages'

  def create
    if User.count < 100
      super

    else
      @user_capacity_error = "The user capacity for the alpha version has been reached"
      render :new

    end
  end


  def account_created
    @page_title = "Account created"
  end

protected

  def after_sign_up_path_for(resource)
    "/account-created"
  end


  def after_update_path_for(resource)
    edit_user_registration_path
  end

end
