class Source
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :activated,   type: Boolean,   default: false
  field :status,      type: String,    default: "unprocessed",   required: true
  
  embeds_many :tracks
  embedded_in :user
  
end
