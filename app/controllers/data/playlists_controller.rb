class Data::PlaylistsController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @playlists = current_user.playlists

    # render
    render json: @playlists.to_json
  end


  def create
    playlist = Playlist.new(params[:playlist])

    # playlist belongs to user
    playlist.user_id = current_user.id

    # save playlist
    playlist.save

    # render json
    render json: playlist
  end


  def update
  end


  def destroy
  end

end
