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
    old_playlists_tracks = playlist.playlists_tracks.all
    new_playlists_tracks = params[:tracks_with_position]

    # other attributes
    if params.try(:[], :playlist).try(:[], :name)
      playlist.name = params[:playlist][:name]
      playlist.save
    end

    # (1) remove
    if new_playlists_tracks
      old_playlists_tracks.each do |old_pt|
        obj = old_pt.attributes.slice("id", "track_id", "position")
        old_pt.delete unless new_playlists_tracks.include?(obj)
      end
    end

    # (2 + 3) update old
    (new_playlists_tracks || []).each_with_index do |new_pt, idx|
      pt = if new_pt["id"]
        playlist.playlists_tracks.find(new_pt["id"])
      end

      if pt
        pt.position = idx + 1
      else
        pt = PlaylistsTrack.new(
          track_id: new_pt["track_id"],
          playlist_id: playlist.id,
          position: idx + 1
        )
      end

      pt.save
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
