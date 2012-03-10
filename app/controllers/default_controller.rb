class DefaultController < ApplicationController
  def index
    # Temporary settings
    @settings = { custom_background: nil }
  end
end