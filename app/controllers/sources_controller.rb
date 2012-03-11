class SourcesController < ApplicationController
  before_filter :require_login
  layout false
  
  # GET 'sources'
  def index
    @sources = [current_user.sources].flatten.sort { |a,b| a.label <=> b.label }
    
    @sources.each do |source|
      source[:available] = source.available?
      source[:label]     = source.label
      
      if source.status.include?('unprocessed') or source.status == 'waiting to be processed'
        source.enqueue_for_processing 
      end
    end
    
    # render
    render json: @sources
  end
end
