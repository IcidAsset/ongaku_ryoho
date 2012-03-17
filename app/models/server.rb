class Server < Source
  
  key :name,       String,   :required => true
  key :location,   String,   :required => true
  
  alias :label :location
  
  
  # check if the server is available
  # and doesn't return any errors
  def available?
    require 'net/http'
    
    uri = URI.parse(self.location + 'available?')
    response = nil
    
    begin
      Net::HTTP.start(uri.host, uri.port) { |http|
        response = http.head(uri.path.size > 0 ? uri.path : '/')
      }
    rescue
      return false
    end
    
    return response.code == '200'
  end
  
  
  # check if there is any music added or removed from the server
  # and then add and/or remove from the database
  def check
    require 'net/http'
    
    # make file list
    file_list = []
    
    self.tracks.each do |track|
      file_list << track.location
    end
    
    # get json data from server
    begin
      uri      = URI.parse(self.location + 'check')
      response = Net::HTTP.post_form(uri, { file_list: file_list.to_json })
    rescue
      return false
    end
    
    # parse json
    parsed_reponse = JSON.parse(response.body)
    missing_files  = parsed_reponse['missing_files']
    new_tracks     = parsed_reponse['new_tracks']
    
    # missing files
    missing_files.each do |missing_file_location|
      self.tracks.delete_if { |track| track.location === missing_file_location }
    end

    server = Server.find(self.user, self.id.to_s, { return_array: true })
    server.tracks = self.tracks
    
    # new_tracks
    Server.add_new_tracks_to_each(server, new_tracks, { dont_save: true })
    
    # last checked
    Server.set_on_each(server, :status, "last updated at #{ Time.now.strftime('%d %b %y / %I:%M %p') }")
  end
  
  
  def process
    require 'net/http'

    # set
    server = Server.find(self.user, self.id.to_s, { return_array: true })

    # processing
    Server.set_on_each(server, :status, 'processing')
    
    # get json data from server
    begin
      uri     = URI.parse(self.location)
      reponse = Net::HTTP.get(uri)
    rescue
      Server.set_on_each(server, :status, 'unprocessed / server not found')
      
      return false
    end
    
    # parse json
    tracks = JSON.parse(reponse)
    
    # no music =(
    if tracks.empty?
      Server.set_on_each(server, :status, 'unprocessed / no music found')

      return false
    end
    
    # put them tracks in them database
    Server.add_new_tracks_to_each(server, tracks)
  end

  handle_asynchronously :process
  

  def self.add_new_tracks_to_each(selected_servers, new_tracks, options={})
    selected_servers.each do |server|
      new_tracks.each do |new_track_tags|
        new_track_tags['url'] = server.location + new_track_tags['location']
        
        track = Track.new(new_track_tags)
        server.tracks << track
      end

      server.status = 'processed'
      server.activated = true
      server.user.save unless options[:dont_save]
    end
  end


  def self.set_on_each(selected_servers, attribute, value, options={})
    selected_servers.each do |server|
      server[attribute] = value
      server.user.save unless options[:dont_save]
    end
  end


  def self.find(user, id, options={})
    server = user.sources.select { |source|
      source._type == 'Server' and source.id.to_s == id
    }

    return options[:return_array] ? server : server.try(:first)
  end

end
