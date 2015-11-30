class SoftwaresController < ResourcesController
  include SortHelpers

  respond_to :html, :js, :xml
  respond_to :json, only: [:index, :show]

  helper_method :sort_column, :sort_direction

  def show
    super do |format|
      format.xml do
        render xml: @software.to_xml(include: { software_instances: { include: [:servers, :software_urls] } },
                                           methods: :dokuwiki_pages)
      end
    end
  end

  def collection
    @softwares ||= end_of_association_chain.search(params[:search]).order_by(mongo_sort_option)
  end
end
