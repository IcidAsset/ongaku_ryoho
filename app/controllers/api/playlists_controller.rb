class Api::PlaylistsController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @playlists = current_user.playlists.includes(:tracks)

    # source ids
    source_ids = params[:source_ids]
    source_ids = source_ids.split(",").map(&:to_i)

    # get special playlists if needed
    unless source_ids.empty?
      specials = Track.get_unique_first_level_directories(source_ids)
      specials.map! { |name| Playlist.new(name: name, special: true) }
      @playlists.concat(specials)
    end

    # render
    render json: @playlists.to_json(
      only: [:id, :name],
      methods: [:tracks_with_position, :track_ids, :special]
    )
  end


  def create
    playlist = Playlist.new(params[:playlist])

    # playlist belongs to user
    playlist.user_id = current_user.id

    # save playlist
    playlist.save

    # render json
    render json: playlist.to_json(
      only: [:id, :name],
      methods: [:tracks_with_position, :track_ids, :special]
    )
  end


  def update
    playlist = current_user.playlists.find(params[:id])

    # collect
    user_id = current_user.id
    playlists_tracks = playlist.playlists_tracks.all
    current_track_ids = playlists_tracks.map(&:track_id)
    updated_track_ids = params[:track_ids]

    # delete tracks
    deleted_track_ids = current_track_ids - updated_track_ids
    existing_track_ids = current_track_ids - deleted_track_ids
    new_track_ids = updated_track_ids - current_track_ids

    playlists_tracks.clone.each do |pt|
      if deleted_track_ids.include?(pt.track_id)
        playlists_tracks.delete_at(playlists_tracks.index(pt))
        pt.delete
      end
    end

    playlists_tracks.each do |pt|
      pt.position = updated_track_ids.index(pt.track_id) + 1
      pt.save
    end

    # add new tracks
    new_track_ids.each_with_index do |track_id, idx|
      pt = PlaylistsTrack.new(
        track_id: track_id,
        playlist_id: playlist.id,
        position: updated_track_ids.index(track_id) + 1
      )

      playlist.playlists_tracks << pt
    end

    # render json
    render json: playlist.to_json(
      only: [:id, :name],
      methods: [:tracks_with_position, :track_ids, :special]
    )
  end


  def destroy
    playlist = current_user.playlists.find(params[:id])
    playlist.destroy() if playlist

    render json: playlist.to_json(
      only: [:id, :name],
      methods: [:tracks_with_position, :track_ids, :special]
    )
  end

end
