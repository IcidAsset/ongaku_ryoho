class UsersController < Devise::RegistrationsController
  before_filter :redirect_if_logged_in, only: [:new, :create]
  layout 'pages'


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
