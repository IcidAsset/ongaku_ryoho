class SourcesController < ApplicationController
  before_filter :require_login
  layout false
  
  # GET 'sources'
  def index
    @sources = [Server.all].flatten.sort { |a,b| a.label <=> b.label }
    
    @sources.each do |source|
      source[:available] = source.available?
      source[:label]     = source.label
      
      source.enqueue_for_processing if source.status.include? 'unprocessed'
    end
    
    # render
    render json: @sources
  end
end
