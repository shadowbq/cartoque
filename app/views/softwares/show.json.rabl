object @software

attributes :id, :name, :description

node(:software_instances) do |appli|
  appli.software_instances.map do |instance|
    { id: instance.id,
      name: instance.name,
      servers: instance.servers,
      software_urls: instance.software_urls.select{|u|u.public?}
    }
  end
end

attributes :dokuwiki_pages

#timestamps
attributes :created_at
attributes :updated_at
