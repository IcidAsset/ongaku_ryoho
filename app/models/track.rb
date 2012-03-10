class Track
  include MongoMapper::EmbeddedDocument
  
  key :title,      String
  key :artist,     String
  key :album,      String
  key :genres,     String
  
  key :tracknr,    Integer
  key :year,       Integer
  
  key :filename,   String
  key :location,   String
  key :url,        String
  
end
