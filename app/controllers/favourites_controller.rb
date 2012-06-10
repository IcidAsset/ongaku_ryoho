class FavouritesController < ApplicationController
  before_filter :require_login
  layout false
  
  def index
    render json: current_user.favourites.all
  end
  
  def create
    favourite = Favourite.new(params[:favourite])
    
    # add to collection
    current_user.favourites << favourite
    
    # save favourite
    favourite.save()
    
    # render json
    render json: favourite
  end
  
  def destroy
    favourite = current_user.favourites.find(params[:id], Favourite)
    
    # destroy favourite
    favourite.destroy()
    
    # render json
    render json: favourite
  end
end