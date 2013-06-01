class Api::SourcesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @sources = current_user.sources.sort { |a, b| a.label <=> b.label }

    # render
    render json: @sources.to_json(
      methods: [:available, :track_amount, :label, :type]
    )
  end


  def show
    @source = current_user.sources.find(params[:id])

    # render
    render json: @source.to_json(
      methods: [:available, :track_amount, :label, :type]
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


  def get_file_list
  end

end
