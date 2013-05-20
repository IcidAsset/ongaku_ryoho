class Api::SourcesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @sources = current_user.sources.sort { |a, b| a.label <=> b.label }

    # render
    render json: @sources.to_json(
      methods: [:available, :track_amount, :label, :busy]
    )
  end


  def show
    @source = current_user.sources.find(params[:id])

    # render
    render json: @source.to_json(
      methods: [:available, :track_amount, :label, :busy]
    )
  end


  def create
    type = params[:source].delete(:type)

    if type
      source = type.constantize.new(
        params[:source], {},
        current_user.id
      )

      if source and source.save
        render json: source
      else
        render nothing: true, status: 403
      end

    else
      render nothing: true, status: 403

    end
  end


  def update; end
  def destroy; end


  def process_source
    source = current_user.sources.find(params[:id])

    # should i?
    allowed_to_proceed = source && !source.busy && !source.processed

    # process if needed
    if allowed_to_proceed
      $redis.sadd(:process_source_queue, source.id)
      source.class.worker.perform_async(
        current_user.id, source.id, :process_tracks
      )
    end

    # render
    render json: { processing: allowed_to_proceed }
  end


  def check_source
    source = current_user.sources.find(params[:id])

    # match unbounded favourites
    # (without a track)
    Favourite.match_unbounded([source.id])

    # should i?
    allowed_to_proceed = source && !source.busy && source.processed

    # check if possible
    if allowed_to_proceed
      $redis.sadd(:check_source_queue, source.id)
      source.class.worker.perform_async(
        current_user.id, source.id, :check_tracks
      )
    end

    # render
    render json: { checking: allowed_to_proceed }
  end

end
