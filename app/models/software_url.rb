class SoftwareUrl
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :public, type: Boolean
  embedded_in :software_instance

  validates_presence_of :url
  validates_presence_of :software_instance
end
