class Api::SourcesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    sources = current_user.sources.sort { |a, b| a.label <=> b.label }

    # render
    render json: sources.to_json(
      methods: [:available, :track_amount, :label, :type, :busy]
    )
  end


  def show
    source = current_user.sources.find(params[:id])

    # render
    render json: source.to_json(
      methods: [:available, :track_amount, :label, :type, :busy]
    )
  end


  def create
    type = params[:source].delete(:type)

    source = type.constantize.new(
      params[:source], {},
      current_user.id
    )

    if source and source.save
      render json: source
    else
      render nothing: true, status: 403
    end
  end


  def update
  end


  def destroy
  end


  #
  #  Members
  #
  def file_list
    source = current_user.sources.find(params[:id])

    # render
    render json: Oj.dump(source.file_list)
  end


  def update_tracks
    source = current_user.sources.find(params[:id])
    data = params[:data]

    # should i?
    allowed_to_proceed = source && !source.busy && data
    allowed_to_proceed = true if allowed_to_proceed

    # process if needed
    if allowed_to_proceed
      source.add_to_redis_queue
      source.class.worker.perform_async(
        current_user.id, source.id, data
      )
    end

    # render
    render json: { working: allowed_to_proceed }
  end

end
