class Source
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :activated,   type: Boolean
  field :status,      type: String,    required: true
  
  embeds_many :tracks
  embedded_in :user
  
end
