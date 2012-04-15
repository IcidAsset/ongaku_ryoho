class TracksController < ApplicationController
  before_filter :require_login
  layout false
  
  def index
    @tracks = []
    
    # get tracks from sources
    sources = current_user.sources.select { |source| source.activated == true }
    sources.each do |source|
      next unless source.available?
      
      @tracks << source.tracks
    end
    
    @tracks.flatten!
    
    # filter
    unless params[:filter].blank?
      filter_regex = /^.*#{params[:filter]}.*$/i
      @tracks.select! { |t| t.title =~ filter_regex or t.artist =~ filter_regex or t.album =~ filter_regex }
    end
    
    # sort
    @tracks = @tracks.sort_by { |t| [t.artist.downcase, t.album.downcase, t.tracknr, t.title.downcase] }
    
    # render
    render json: @tracks
  end
end
