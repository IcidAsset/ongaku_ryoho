class DefaultController < ApplicationController

  def index
    if logged_in?
      render "default/index", layout: "default"
    else
      redirect_to "/about"
    end
  end

end
