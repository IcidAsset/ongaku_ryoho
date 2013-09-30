class DefaultController < ApplicationController
  before_filter :set_cache_buster

  def index
    if logged_in?
      render "default/index"
    else
      redirect_to "/about"
    end
  end

end
