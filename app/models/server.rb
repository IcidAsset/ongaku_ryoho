class Server < Source

  #
  #  Worker
  #
  def self.worker
    ServerWorker
  end


  #
  #  Override ActiveRecord::Base.new
  #
  def self.new(attributes=nil, options={}, user_id, ip_address)
    location = attributes[:configuration][:location]
    location = "http://#{location}" unless location.include?('http://')
    location << (location.end_with?('/') ? '' : '/')

    attributes[:configuration] ||= {}
    attributes[:configuration].merge!({ location: location, boundary: ip_address })
    attributes[:processed] = false

    server = super(attributes, options)
    server.user_id = user_id
    server
  end


  #
  #  Utility functions
  #
  def self.add_new_tracks(server, new_tracks)
    return unless new_tracks.present?

    # attributes -> models
    new_track_models = new_tracks.map do |tags|
      tags["tracknr"] = tags.delete("track") || ""
      tags["url"] = server.configuration["location"] + tags["location"]

      tags.each do |tag, value|
        new_value = if !value
          "Unknown"
        elsif value.is_a?(String) and value.length > 255
          value[0...255]
        else
          value
        end

        new_value = new_value.encode("UTF-8", "binary",
          invalid: :replace, undef: :replace, replace: ""
        ) if new_value.is_a?(String)

        tags[tag] = new_value
      end

      new_track_model = Track.new(tags)
      new_track_model.source_id = server.id

      new_track_model
    end

    # save models
    ActiveRecord::Base.transaction do
      new_track_models.each(&:save)
    end
  end


  def self.remove_tracks(server, missing_files)
    return unless missing_files.present?

    # collect tracks
    tracks = Track.where(location: missing_files, source_id: server.id)

    # destroy tracks
    tracks.destroy_all
  end

end
