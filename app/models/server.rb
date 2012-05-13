class Server < Source
  
  field :name,       type: String,   required: true
  field :location,   type: String,   required: true
  
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
  def check_tracks
    require 'net/http'
    
    # processing
    self.status = 'processing'
    
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
      self.status = 'processed'
      self.save
      
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
    
    # new_tracks
    Server.add_new_tracks(self, new_tracks)
    
    # last checked
    self.status = "last updated at #{ Time.now.strftime('%d %b %y / %I:%M %p') }"

    # did something change?
    changed = (new_tracks.length + missing_files.length === 0) ? false : true 

    # the end
    self.save
    
    # return
    return changed
  end


  def process_tracks
    require 'net/http'

    # processing
    self.status = 'processing'
    
    # get json data from server
    begin
      uri     = URI.parse(self.location)
      reponse = Net::HTTP.get(uri)
    rescue
      self.status = 'unprocessed / server not found'
      self.save
      
      return false
    end
    
    # parse json
    tracks = JSON.parse(reponse)
    
    # no music =(
    if tracks.empty?
      self.status = 'unprocessed / no music found'
      self.save

      return false
    end
    
    # put them tracks in them database
    Server.add_new_tracks(self, tracks)
    
    # the end
    self.save
  end


  def self.add_new_tracks(server, new_tracks)
    new_tracks.each do |new_track_tags|
      new_track_tags['url'] = server.location + new_track_tags['location']
      server.tracks.build(new_track_tags)
    end

    server.status = 'processed'
    server.activated = true
  end

end
