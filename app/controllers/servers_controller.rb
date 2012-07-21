class ServersController < ApplicationController
  before_filter :require_login
  layout false

  # GET 'servers'
  def index
    render json: current_user.servers.all
  end

  # GET 'servers/:id'
  def show
    @server = current_user.servers.find(params[:id])
  end

  # GET 'servers/new'
  def new
    @server = Server.new
  end

  # POST 'servers'
  def create
    location = params[:server].delete(:location)
    location = "http://#{location}" unless location.include?('http://')
    location << (location.end_with?('/') ? '' : '/')

    server = Server.new
    server.user_id = current_user.id
    server.name = location.gsub('http://', '').gsub('/', '')
    server.configuration = { location: location }

    existing_server = Server.all.select { |s|
      s.configuration[:location] == location
    }.first

    unless existing_server
      if server.save
        @server = server

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
