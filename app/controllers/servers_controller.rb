class ServersController < ApplicationController
  before_filter :require_login
  layout false
  
  # GET 'servers/:id'
  def show
    @server = current_user.sources.select { |source|
      source._type == 'Server' and source.id.to_s == params[:id]
    }.first
  end
  
  # GET 'servers/new'
  def new
    @server = Server.new
  end
  
  # POST 'servers'
  def create
    server = Server.new(params[:server])

    server.activated = false
    server.status = 'unprocessed'
    server.location = "http://#{server.location}" unless server.location.include?('http://')
    server.location << (server.location.end_with?('/') ? '' : '/')
    server.name = server.location.gsub('http://', '').gsub('/', '')

    existing_source = current_user.sources.select { |source|
      source._type == 'Server' and source.location == server.location
    }.first

    unless existing_source
      current_user.sources << server

      if server.save
        @server = server

        # process
        @server.enqueue_for_processing

        # redirect
        return redirect_to @server
      end
    end

    redirect_to new_server_path
  end
  
  # The Rest
  def edit; end
  def update; end
  def destroy; end
end
