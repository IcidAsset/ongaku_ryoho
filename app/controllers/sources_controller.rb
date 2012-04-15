class SourcesController < ApplicationController
  before_filter :require_login
  layout false

  # GET 'sources'
  def index
    @sources = current_user.sources.sort { |a,b| a.label <=> b.label }

    @sources.each do |source|
      source[:available] = source.available?
      source[:label]     = source.label

      unless source.in_queue
        source.in_queue = true
        source.user.save
        
        if source.status.include?('unprocessed')
          source.process
        else
          source.check
        end
      end
    end

    # render
    render json: @sources
  end
end
