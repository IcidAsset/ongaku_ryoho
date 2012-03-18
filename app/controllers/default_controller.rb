class DefaultController < ApplicationController
  before_filter :require_login

  def index
    # Temporary settings
    @settings = { custom_background: nil }

    # Source manager add forms
    @server = Server.new
    @bucket = Bucket.new
  end
end