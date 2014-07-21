class SessionsController < Devise::SessionsController
  before_filter :redirect_if_logged_in, only: [:new]
  layout 'pages'
end
