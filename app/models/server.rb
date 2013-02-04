class Server < Source
  attr_accessor :location

  def self.worker
    ServerWorker
  end


  def label
    label = if name.blank? and configuration[:location]
      configuration[:location]
    else
      name
    end

    "#{type} &mdash; #{label}"
  end


  # check if the server is available
  # and doesn't return any errors
  def available?
    require "net/http"

    uri = URI.parse(self.configuration[:location])
    response = nil

    begin
      Net::HTTP.start(uri.host, uri.port) { |http|
        response = http.head(uri.path.size > 0 ? uri.path : "/")
      }
    rescue
      return false
    end

    return response.code == "200"
  end


  #
  #  Utility functions
  #
  def self.add_new_tracks(server, new_tracks)
    new_track_models = new_tracks.map do |tags|
      tags.delete("last_modified")

      tags["tracknr"] = tags.delete("track") || ""
      tags["url"] = server.configuration[:location] + tags["location"]

      tags.each do |tag, value|
        condition = value.is_a?(String) and value.length > 255
        tags[tag] = value[0...255] if condition
      end

      new_track_model = Track.new(tags)
      new_track_model.source_id = server.id

      new_track_model
    end

    ActiveRecord::Base.transaction do
      new_track_models.each(&:save)
    end

    server.activated = true
  end


  def self.remove_tracks(server, missing_files)
    return if missing_files.length == 0

    # collect tracks
    tracks = Track.where(location: missing_files, source_id: server.id)
    tracks_with_favourites = tracks.where("favourite_id IS NOT NULL").all

    # remove track_id from related favourites
    tracks_with_favourites.each do |track|
      track.favourite.track_id = nil
      track.favourite.save
    end

    # destroy tracks
    tracks.destroy_all
  end

end
