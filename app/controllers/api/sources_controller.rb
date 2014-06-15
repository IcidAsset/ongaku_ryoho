class Api::SourcesController < ApplicationController
  before_filter :require_login
  layout false

  def index
    sources = current_user.sources.sort { |a, b| a.name <=> b.name }

    # render
    render json: sources.to_json(
      methods: [:track_amount, :type, :busy]
    )
  end


  def show
    source = current_user.sources.find(params[:id])

    # render
    render json: source.to_json(
      methods: [:track_amount, :type, :busy]
    )
  end


  def create
    type = params.delete(:type)

    source = type.constantize.new(
      params[:source], {},
      current_user.id, request.remote_ip
    )

    if source and source.save
      render json: source
    else
      render nothing: true, status: 500
    end
  end


  def update
    source = Source.find(params[:source][:id])

    attrs = params[:source]
    attrs[:configuration] = source.configuration.merge(attrs[:configuration] || {})
    source.update_with_selected_attributes(attrs)

    render json: source
  end


  def destroy
    source = Source.find(params[:id])
    source.destroy

    render json: source
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
    data = params[:data] || "{}"

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
    is_working = !!(source && source.busy) || allowed_to_proceed
    render json: Oj.dump({ "working" => is_working })
  end


  #
  #  Members / S3 Bucket
  #
  def s3_signed_url
    source = current_user.sources.find(params[:id])
    path = URI.unescape(params[:track_location])
    expire_date = DateTime.now.tomorrow.to_i
    signed_url = source.signed_url(path, expire_date, params[:host])

    render json: Oj.dump({
      "signed_url" => signed_url,
      "expire_date" => expire_date
    })
  end


  #
  #  Members / Dropbox
  #
  def dropbox_media_url
    dropbox = current_user.sources.find(params[:id])
    access_token = dropbox.configuration["access_token"]
    dropbox_client = DropboxClient.new(access_token)
    path = URI.unescape(params[:track_location])
    media_response = dropbox_client.media(path)

    render json: Oj.dump({
      "media_url" => media_response["url"],
      "expire_date" => media_response["expires"]
    })
  end


  #
  #  Collection / Dropbox
  #
  def dropbox_authorize_url
    flow = DropboxOAuth2FlowNoRedirect.new(DropboxAccount::APP_KEY, DropboxAccount::APP_SECRET)
    authorize_url = flow.start

    render json: Oj.dump({
      "authorize_url" => authorize_url
    })
  end

end
