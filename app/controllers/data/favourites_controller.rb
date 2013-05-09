class Data::FavouritesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    render json: current_user.favourites.all,
           except: [:search_vector]
  end


  def create
    favourite = Favourite.new
    track = Track.find(params[:favourite][:track_id])

    # favourite belongs to user
    favourite.user_id = current_user.id

    # if track
    if track
      attributes = { track_id: track.id }

      %w(artist title album genre track_nr year filename location url).each do |attribute|
        attributes[attribute] = track.send(attribute.to_sym)
      end

      favourite.assign_attributes(attributes)
    else
      favourite.assign_attributes(params[:favourite])
    end

    # save favourite
    if favourite.save
      if track
        track.favourite_id = favourite.id
        track.save
      end
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
