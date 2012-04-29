class SourcesController < ApplicationController
  before_filter :require_login
  layout false

  # GET 'sources'
  def index
    @sources = current_user.sources.sort { |a,b| a.label <=> b.label }

    @sources.each do |source|
      source[:available] = source.available?
      source[:label]     = source.label
    end

    # render
    render json: @sources
  end
  
  # GET 'sources/:id/process'
  def process_source
    source = current_user.sources.find(params[:id])
    
    # process if needed
    source.process if source and source.status.include?('unprocessed') and !source.status.include?('processing')
  end
  
  # GET 'sources/:id/check'
  def check_source
    source = current_user.sources.find(params[:id])
    
    # check if possible
    render json: { changed: source.check } if source and !source.status.include?('processing')
  end
  
end