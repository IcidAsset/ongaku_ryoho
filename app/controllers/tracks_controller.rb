class TracksController < ApplicationController
  layout false
  
  def index
    @tracks = []
    
    # get tracks from sources
    Source.where(:activated => true).each do |source|
      next unless source.available?
      
      @tracks << source.tracks
    end
    
    # sort tracks
    @tracks.flatten!
    @tracks = @tracks.sort { |a,b| a.artist.downcase <=> b.artist.downcase }
    
    # render
    render json: @tracks
  end
  
end
