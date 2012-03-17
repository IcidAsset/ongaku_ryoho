class DefaultController < ApplicationController
  before_filter :require_login
  
  def index
    # Temporary settings
    @settings = { custom_background: nil }
  end
end