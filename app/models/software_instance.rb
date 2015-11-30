class SoftwareInstance
  include Mongoid::Document
  include Mongoid::Alize
  include Mongoid::Timestamps
  include ConfigurationItem

  #standard fields
  field :name, type: String
  field :authentication_method, type: String
  #associations
  embeds_many :software_urls
  belongs_to :software
  has_and_belongs_to_many :servers
  #denormalized fields
  alize :software, :name

  accepts_nested_attributes_for :software_urls, reject_if: lambda{|a| a[:url].blank? },
                                                   allow_destroy: true

  #default_scope includes(:software).order("softwares.name, software_instances.name")

  AVAILABLE_AUTHENTICATION_METHODS = %w(none cerbere cerbere-cas cerbere-bouchon ldap-minequip internal other)

  validates_presence_of :name, :authentication_method, :software
  validates_inclusion_of :authentication_method, in: AVAILABLE_AUTHENTICATION_METHODS

  def full_name
    "#{software_name} (#{name})"
  end
  alias :to_s :full_name

  def software_name
    software_fields.try(:fetch, 'name') if software_id.present?
  end
end
