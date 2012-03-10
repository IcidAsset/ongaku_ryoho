class ServersController < ApplicationController
  before_filter :require_login
  layout false
  
  # GET 'servers/:id'
  def show
    @server = Server.find(params[:id])
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
    
    @server = server
    
    if @server.save
      # process
      @server.enqueue_for_processing
      
      # redirect
      redirect_to @server
    else
      redirect_to new_server_path
    end
  end
  
  # The Rest
  def edit; end
  def update; end
  def destroy; end
end
