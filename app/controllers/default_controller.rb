class DefaultController < ApplicationController

  def index
    if logged_in?
      render "default/index"
    else
      redirect_to "/about"
    end
  end

end
