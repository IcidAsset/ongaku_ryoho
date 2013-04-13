class Data::PlaylistsController < ApplicationController
  before_filter :require_login
  layout false

  def index
    @playlists = current_user.playlists

    # render
    render json: @playlists.to_json
  end


  def create
  end


  def update
  end


  def destroy
  end

end
