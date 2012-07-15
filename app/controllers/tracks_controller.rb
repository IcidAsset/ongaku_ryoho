class TracksController < ApplicationController
  before_filter :require_login
  layout false
  
  def index
    tracks = []
    
    # get tracks from sources
    sources = current_user.sources.where(activated: true).all
    sources.each do |source|
      next unless source.available?
      
      tracks << source.tracks
    end
    
    tracks.flatten!
    
    # favourites
    favourites = current_user.favourites.all
    
    tracks.each do |t|
      favourite_matches = favourites.select { |f|
        f.track_title == t.title and f.track_artist == t.artist
      }
      
      t.favourite = favourite_matches.length > 0
      t.available = true
      
      favourites = favourites - favourite_matches
    end
    
    if params[:favourites] == "true"
      favourite_tracks = tracks.select(&:favourite)
      
      favourites.each do |f|
        favourite_tracks << Track.new({
          title: f.track_title,
          artist: f.track_artist,
          album: "",
          tracknr: "",
          genre: "",
          favourite: true,
          available: false
        })
      end
      
      tracks = favourite_tracks
    end
    
    # filter
    unless params[:filter].blank?
      filter_regex = /^.*#{params[:filter]}.*$/i
      tracks.select! { |t| t.title =~ filter_regex or t.artist =~ filter_regex or t.album =~ filter_regex }
    end
    
    # sort
    tracks = case params[:sort_by].try(:to_sym)
    when :title
      tracks.sort_by { |t| [t.title.downcase, t.tracknr, t.artist.downcase, t.album.downcase] }
    when :album
      tracks.sort_by { |t| [t.album.downcase, t.tracknr, t.artist.downcase, t.title.downcase] }
    else
      tracks.sort_by { |t| [t.artist.downcase, t.album.downcase, t.tracknr, t.title.downcase] }
    end
    
    # sort direction
    tracks.reverse! if params[:sort_direction] == 'desc'
    
    # pagination
    page = params[:page].to_i
    per_page = params[:per_page].to_i
    total = tracks.length
    
    tracks = tracks.slice((page - 1) * per_page, per_page)
    
    # render
    render json: {
      page: page,
      per_page: per_page,
      total: total,
      models: tracks
    }.to_json(methods: [:favourite, :available])
  end
end
