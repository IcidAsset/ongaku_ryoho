class Source
  include MongoMapper::Document
  
  key :activated,   Boolean
  key :status,      String,    :required => true
  
  many :tracks
  
  timestamps!
  
end
