class StaffTraining::PtbudgetsController < ApplicationController
  filter_access_to :index, :new, :create, :attribute_check => false
  filter_access_to :show, :edit, :update, :destroy, :attribute_check => true
  helper_method :sort_column, :sort_direction
  before_action :set_ptbudget, only: [:show, :edit, :update, :destroy]
  #filter_resource_access
  # GET /ptbudgets
  # GET /ptbudgets.xml
  def index
    @search = Ptbudget.search(params[:q])
    @ptbudgets = @search.result.order(fiscalstart: :desc)
    @budgets = @ptbudgets
    @ptbudgets = @ptbudgets.page(params[:page]||1)
  end

  # GET /ptbudgets/1
  # GET /ptbudgets/1.xml
  def show
    @ptbudget = Ptbudget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ptbudget }
    end
  end

  # GET /ptbudgets/new
  # GET /ptbudgets/new.xml
  def new
    @ptbudget = Ptbudget.new
    @newtype = params[:newtype]
    #@ptbudget.fiscalstart = Ptbudget.last.fiscalstart + 1.year rescue Date.today

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ptbudget }
    end
  end

  # GET /ptbudgets/1/edit
  def edit
    @ptbudget = Ptbudget.find(params[:id])
  end

  # POST /ptbudgets
  # POST /ptbudgets.xml
  def create
    @newtype = params[:newtype]
    @ptbudget = Ptbudget.new(ptbudget_params)
    if @newtype.nil?
      ab=@ptbudget.fiscalstart
      if ab.month==@ptbudget.budget_start.month && ab.day==@ptbudget.budget_start.day
        @newtype="1"
      else
        @newtype="2"
      end
    end
    respond_to do |format|
      if @ptbudget.save
        flash[:notice] = t('ptbudgets.budget')+t('actions.created')
        format.html { redirect_to staff_training_ptbudgets_path(@ptbudget)}
        format.json { render action: 'show', status: :created, location: @ptbudget }
      else
        format.html { render action: 'new' }
        format.json { render json: @ptbudget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ptbudgets/1
  # PUT /ptbudgets/1.xml
  def update
    @ptbudget = Ptbudget.find(params[:id])

    respond_to do |format|
      if @ptbudget.update_attributes(ptbudget_params)
        flash[:notice] =t('ptbudgets.budget')+t('actions.updated')
        format.html { redirect_to(staff_training_ptbudgets_path(@ptbudget)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ptbudgets.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ptbudgets/1
  # DELETE /ptbudgets/1.xml
  def destroy
    @ptbudget = Ptbudget.find(params[:id])
    @ptbudget.destroy

    respond_to do |format|
      format.html { redirect_to(staff_training_ptbudgets_path) }
      format.xml  { head :ok }
    end
  end
end

private
    # Use callbacks to share common setup or constraints between actions.
    def set_ptbudget
      @ptbudget = Ptbudget.find(params[:id])
      @budget = @ptbudget
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ptbudget_params
      params.require(:ptbudget).permit(:fiscalstart, :budget, :used_budget, :budget_balance)
    end
    
    def sort_column
        Ptbudget.column_names.include?(params[:sort]) ? params[:sort] : "fiscal_end" 
    end
    
    def sort_direction
        %w[asc desc].include?(params[:direction])? params[:direction] : "asc" 
    end