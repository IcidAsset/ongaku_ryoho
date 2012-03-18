class BucketsController < ApplicationController
  before_filter :require_login
  layout false

  # GET 'buckets/:id'
  def show
    @bucket = Bucket.find(current_user, params[:id])
  end

  # GET 'buckets/new'
  def new
    @bucket = Bucket.new
  end

  # POST 'buckets'
  def create
    bucket = Bucket.new(params[:bucket])

    bucket.activated = false
    bucket.status = 'unprocessed'

    existing_source = current_user.sources.select { |source|
      source._type == 'Bucket' and source.access_key_id == bucket.access_key_id
    }.first

    unless existing_source
      current_user.sources << bucket

      if bucket.save
        @bucket = bucket

        # process
        @bucket.process

        # redirect
        return redirect_to @bucket
      end
    end

    redirect_to new_bucket_path
  end

  # The Rest
  def edit; end
  def update; end
  def destroy; end
end
