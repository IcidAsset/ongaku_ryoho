class Data::PlaylistsController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @playlists = current_user.playlists.includes(:tracks)

    # special playlists
    specials = Track.get_unique_first_level_directories(current_user)
    specials.map! { |name| Playlist.new(name: name, special: true) }
    @playlists.concat(specials)

    # render
    render json: @playlists.to_json(only: [:id, :name], methods: [:track_ids, :special])
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
