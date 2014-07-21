class PasswordsController < Devise::PasswordsController
  before_filter :redirect_if_logged_in, only: [:new]
  layout 'pages'

  protected

  def after_resetting_password_path_for(resource_name)
    "/account"
  end

end
