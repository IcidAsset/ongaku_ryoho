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
    attributes[:name].strip!

    location = attributes[:configuration][:location].strip
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
        tags[tag] = Source.parse_track_tag_value(value)
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
