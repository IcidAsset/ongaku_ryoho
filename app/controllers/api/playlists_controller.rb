class Api::PlaylistsController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @playlists = current_user.playlists.includes(:tracks)

    # source ids
    source_ids = params[:source_ids]

    # get special playlists if needed
    unless source_ids.empty?
      specials = Track.get_unique_first_level_directories(source_ids)
      specials.map! { |name| Playlist.new(name: name, special: true) }
      @playlists.concat(specials)
    end

    # render
    render json: @playlists.to_json(
      only: [:id, :name],
      methods: [:track_ids, :special]
    )
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
    playlist = Playlist.find(params[:id])
    return unless playlist

    user_id = current_user.id

    new_track_ids = params[:track_ids] - playlist.tracks.map(&:id)
    new_track_ids.each do |track_id|
      track = Track.where(id: track_id).first
      playlist.tracks << track if track
    end

    # TODO: security
    # TODO: old_track_ids

    playlist.save

    # render json
    render json: playlist
  end


  def destroy
  end

end
