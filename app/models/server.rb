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
    
    self.save
    
    # new_tracks
    self.add_new_tracks(new_tracks)
    
    # last checked
    self.set(status: "last updated at #{ Time.now.strftime('%d %b %y / %I:%M %p') }")
  end
  
  
  def add_new_tracks(new_tracks)
    server = self
    
    new_tracks.each do |new_track_tags|
      new_track_tags['url'] = server.location + new_track_tags['location']
      
      track = Track.new(new_track_tags)
      server.push(tracks: track.to_mongo)
    end
  end
  
  
  def enqueue_for_processing
    Navvy::Job.enqueue(Server, :process, self)
    
    self.status = 'waiting to be processed'
    self.user.save
  end
  
  
  def self.process(server)
    require 'net/http'
    
    # processing
    server.status = 'processing'
    server.user.save
    
    # get json data from server
    begin
      uri     = URI.parse(server.location)
      reponse = Net::HTTP.get(uri)
    rescue
      server.status = 'unprocessed / server not found'
      server.user.save
      
      return false
    end
    
    # parse json
    tracks = JSON.parse(reponse)
    
    # no music =(
    if tracks.empty?
      server.status = 'unprocessed / no music found'
      server.user.save

      return false
    end
    
    # put them tracks in them database
    server.add_new_tracks(tracks)
    
    # processed
    server.status = 'processed'
    server.activated = true
    server.user.save
  end
  
end
