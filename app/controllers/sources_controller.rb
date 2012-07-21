class SourcesController < ApplicationController
  before_filter :require_login
  layout false

  # GET 'sources'
  def index
    @sources = current_user.sources.sort { |a,b| a.label <=> b.label }

    # render
    render json: @sources.to_json(
      methods: [:available, :track_amount, :label]
    )
  end

  # GET 'sources/:id/process'
  def process_source
    source = current_user.sources.find(params[:id])

    # should i?
    allowed_to_proceed = (
      source and
      source.status.include?('unprocessed') and
      !source.status.include?('processing')
    )

    # process if needed
    json = if allowed_to_proceed
      { changed: true }
    else
      { changed: false }
    end
  end

  # GET 'sources/:id/check'
  def check_source
    source = current_user.sources.find(params[:id])

    # should i?
    allowed_to_proceed = (
      source and !source.status.include?('processing')
    )

    # check if possible
    json = if allowed_to_proceed
      { changed: source.check_tracks, checked: true }
    else
      { changed: false, checked: false }
    end

    # render
    render json: json
  end

end
