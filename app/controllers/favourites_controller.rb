class FavouritesController < ApplicationController
  before_filter :require_login
  layout false
  
  def index
    render json: current_user.favourites.all
  end
  
  def create
    favourite = Favourite.new(params[:favourite])
    
    # favourite belongs to user
    favourite.user_id = current_user.id
    
    # save favourite
    favourite.save
    
    # render json
    render json: favourite
  end
  
  def destroy
    favourite = current_user.favourites.find(params[:id])
    
    # destroy favourite
    favourite.destroy
    
    # render json
    render json: favourite
  end
end