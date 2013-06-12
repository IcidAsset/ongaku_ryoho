class Api::FavouritesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    render json: current_user.favourites.all,
           except: [:search_vector]
  end


  def create
    favourite = Favourite.new
    track = Track.find(params[:favourite][:track_id])

    # check
    unless track
      render json: {}
      return
    end

    # favourite belongs to user
    favourite.user_id = current_user.id

    # copy the track's attributes
    attributes = {}

    %w(artist title album genre tracknr year filename location url).each do |attribute|
      attributes[attribute] = track.send(attribute.to_sym)
    end

    favourite.assign_attributes(attributes)

    # save favourite
    if favourite.save
      favourite.bind_track(track)
    end

    # render json
    render json: favourite
  end


  def destroy
    favourite = current_user.favourites.find(params[:id])

    # related track
    track = favourite.track

    # reset track attributes
    if track
      track.favourite_id = nil
      track.save
    end

    # destroy favourite
    favourite.destroy

    # render json
    render json: favourite
  end

end
