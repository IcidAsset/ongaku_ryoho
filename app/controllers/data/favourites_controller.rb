class Data::FavouritesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    render json: current_user.favourites.all,
           except: [:search_vector]
  end

  def create
    favourite = Favourite.new(params[:favourite])

    # favourite belongs to user
    favourite.user_id = current_user.id

    # save favourite
    if favourite.save
      track = Track.find(favourite.track_id)
      track.favourite_id = favourite.id
      track.save
    end

    # render json
    render json: favourite
  end

  def destroy
    favourite = current_user.favourites.find(params[:id])

    # related track
    track = favourite.track
    track.favourite_id = nil
    track.save

    # destroy favourite
    favourite.destroy

    # render json
    render json: favourite
  end
end
