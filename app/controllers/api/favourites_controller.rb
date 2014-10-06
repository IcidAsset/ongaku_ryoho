class Api::FavouritesController < ApplicationController
  before_filter :authenticate_user!
  layout false

  def index
    render json: current_user.favourites.all,
           except: [:search_vector]
  end


  def create
    favourite = Favourite.new
    track = Track.find(params[:track_id])

    # check
    unless track
      render json: {}
      return
    end

    # favourite belongs to user
    favourite.user_id = current_user.id

    # copy the track's attributes
    attributes = {}

    %w(artist title album).each do |attribute|
      attributes[attribute] = track.send(attribute.to_sym)
    end

    favourite.assign_attributes(attributes)

    # save favourite
    if favourite.save
      if favourite.has_unknown_tags?
        favourite.bind_track(track)
      else
        Favourite.bind_favourites_with_tracks(favourite.user_id, favourite)
      end
    end

    # render json
    render json: favourite
  end


  def destroy
    favourite = current_user.favourites.find(params[:id])

    # reset tracks
    favourite.track_ids.each do |source_id, track_ids|
      track_ids = track_ids.split(",")
      track_ids.each do |track_id|
        track = Track.find(track_id) rescue nil
        if track
          track.favourite_id = nil
          track.save
        end
      end
    end

    # destroy favourite
    favourite.destroy

    # render json
    render json: favourite
  end

end
