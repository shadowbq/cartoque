class SoftwareDecorator < ResourceDecorator
  decorates :software

  def title
    h.content_tag :h2, model.name
  end
end
