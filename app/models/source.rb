class Source
  include MongoMapper::EmbeddedDocument
  
  key :activated,   Boolean
  key :in_queue,    Boolean,   :default => false
  key :status,      String,    :required => true
  
  many :tracks
  embedded_in :user
  
  timestamps!
  
end
