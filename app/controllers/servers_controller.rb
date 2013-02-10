class ServersController < ApplicationController
  before_filter :require_login
  layout false

  def index
    render json: current_user.servers.all
  end


  def new
    @server = Server.new
  end


  def create
    location = params[:server].delete(:location)
    location = "http://#{location}" unless location.include?('http://')
    location << (location.end_with?('/') ? '' : '/')

    server = Server.new
    server.user_id = current_user.id
    server.name = location.gsub('http://', '').gsub('/', '')
    server.configuration = { location: location }
    server.status = "unprocessed"

    existing_server = Server.all.select { |s|
      s.configuration[:location] == location
    }.first

    unless existing_server
      if server.save
        @server = server

        return render json: @server
      end
    end

    redirect_to new_server_path
  end


  def edit; end
  def update; end
  def destroy; end

end
