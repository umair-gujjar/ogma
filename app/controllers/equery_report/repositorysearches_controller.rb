class EqueryReport::RepositorysearchesController < ApplicationController
  filter_resource_access
  
  def new
    @repositorysearch = Repositorysearch.new
    @reposearch=params[:searchrepotype]
  end
  
  def create
    @repositorysearch = Repositorysearch.new(repositorysearch_params)
    if @repositorysearch.save
      redirect_to equery_report_repositorysearch_path(@repositorysearch)
    else
      render action:new
    end
  end
  
  def show
    @repositorysearch = Repositorysearch.find(params[:id])
    @repositories=@repositorysearch.repositories.page(params[:page]).per(10)
  end
 
  private
   
    def repositorysearch_params
      params.require(:repositorysearch).permit(:title, :vessel, :document_type, :document_subtype, :refno, :publish_date, :total_pages, :copies, :location, :repotype, [:keyword =>{}], :college_id, [:data =>{}])
    end
   
end