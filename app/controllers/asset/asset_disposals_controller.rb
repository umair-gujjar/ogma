class Asset::AssetDisposalsController < ApplicationController
  filter_access_to :index, :new, :create, :kewpa16, :kewpa18, :kewpa19, :kewpa17_20, :kewpa17, :kewpa20, :attribute_check => false
  filter_access_to :show, :edit, :update, :destroy, :revalue, :dispose, :verify, :view_close, :attribute_check => true
  before_action :set_disposed, only: [:show, :edit, :update, :destroy]
  
  def index
    /@disposals = AssetDisposal.order(code: :asc).page(params[:page]||1)/
    @search = AssetDisposal.search(params[:q])
    @disposals = @search.result
    @disposals = @disposals.page(params[:page]||1)  
  end
  
  def new
    @disposal = AssetDisposal.new
  end
  
  # POST /asset_disposals
  # POST /asset_disposals.xml
  def create
    @disposal = AssetDisposal.new(asset_disposal_params)
    respond_to do |format|
      if @disposal.save
        format.html { redirect_to(asset_disposal_path(@disposal), :notice => t('asset.disposal.title')+t('actions.created')) }
        format.xml  { render :xml => @disposal, :status => :created, :location => @disposal}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @disposal.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @disposal = AssetDisposal.find(params[:id])
  end
  
  def update
    @disposal = AssetDisposal.find(params[:id])  
    editingpage = params[:asset_disposal][:editing_page]
    respond_to do |format|
      if @disposal.update(asset_disposal_params)
        format.html { redirect_to asset_disposal_path, notice: t('asset.disposal.title')+t('actions.updated')}
        format.json { head :no_content }
      else
	if editingpage=="verify"
	  format.html { render action: 'verify'}
	elsif editingpage=="dispose"
	  format.html { render action: 'dispose'}
	elsif editingpage=="revalue"
	  format.html { render action: 'revalue'}
	elsif editingpage=="view_close"
	  format.html { render action: 'view_close'}
	else 
          format.html { render action: 'edit' }
	end
        format.json { render json: @asset_disposal.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def revalue
    @disposal = AssetDisposal.find(params[:id])
    @disposed = @disposal
  end
  
  def dispose
    @disposal = AssetDisposal.find(params[:id])
    @disposed = @disposal
  end
  
  def verify
    @disposal = AssetDisposal.find(params[:id])
    @disposed = @disposal
  end
  
  def view_close
    @disposal = AssetDisposal.find(params[:id])
    @disposed = @disposal
  end
  
  def show
    @disposed = AssetDisposal.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @disposed }
    end
  end
  
  def kewpa17_20
    commit = params[:commit]
    if params[:disposal_ids]
      disposed_ids = params[:disposal_ids]
      dpids=[]
      disposed_ids.each do |dp|
        dpids << dp.to_i
      end    
    end
    if commit == 'KEW.PA-17' && dpids
      redirect_to  kewpa17_asset_disposals_path(:format => 'pdf', :disposalids => dpids)
    elsif commit == 'KEW.PA-20' && dpids
      redirect_to kewpa20_asset_disposals_path(:format => 'pdf', :disposalids => dpids)
    else
      redirect_to asset_disposals_path
      #flash[:notice]=> "No record selected"
    end
  end

  def kewpa17
    if params[:disposalids]
      @disposals_all = AssetDisposal.where('is_disposed is not TRUE').where('id IN(?)', params[:disposalids]).order(created_at: :desc)
    else
      @disposals_all = AssetDisposal.where('is_disposed is not TRUE').order('created_at DESC')
    end
    @disposal_last = @disposals_all.last
    @disposal_last_id = @disposal_last.id
    if @disposals_all.count==1
      @disposals=AssetDisposal.where('id IN(?)', @disposals_all.map(&:id))
    else
      @disposals=AssetDisposal.where('id IN(?) and id !=?', @disposals_all.map(&:id), @disposal_last_id)
    end
    respond_to do |format|
      format.pdf do
        pdf = Kewpa17Pdf.new(@disposals,@disposal_last,  view_context)
        send_data pdf.render, filename: "kewpa17-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  def kewpa20
     if params[:disposalids]
      @disposals = AssetDisposal.where('id IN(?)', params[:disposalids]).order(created_at: :desc)
    else
      @disposals = AssetDisposal.order('created_at DESC')
    end
    respond_to do |format|
      format.pdf do
        pdf = Kewpa20Pdf.new(@disposals, view_context)
        send_data pdf.render, filename: "kewpa20-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  def kewpa16
    @disposal = AssetDisposal.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = Kewpa16Pdf.new(@disposal, view_context)
        send_data pdf.render, filename: "kewpa16-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  def kewpa18
    @disposal = AssetDisposal.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = Kewpa18Pdf.new(@disposal, view_context)
        send_data pdf.render, filename: "kewpa18-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  def kewpa19
    @lead = Position.find(1)
    @disposal = AssetDisposal.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = Kewpa19Pdf.new(@disposal, view_context, @lead)
        send_data pdf.render, filename: "kewpa19-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  def destroy
    @disposed.destroy
    respond_to do |format|
      format.html { redirect_to(asset_disposals_url) }
      format.xml  { head :ok }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_disposed
      @disposed = AssetDisposal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_disposal_params
      params.require(:asset_disposal).permit(:asset_id, :description, :running_hours, :mileage, :current_condition,:current_value, :est_repair_cost,:est_value_post_repair, :est_time_next_fail, :repair1_needed, :repair2_needed,:repair3_needed,:justify1_disposal, :justify2_disposal,:justify3_disposal,:is_checked, :checked_on, :is_verified,:verified_on, :revalue, :revalued_by,:revalued_on, :document_id, :disposal_type,:type_others_desc, :discard_options,:receiver_name,:documentation_no, :is_disposed, :inform_hod,:disposed_by, :disposed_on, :is_discarded, :discarded_on, :discard_location, :discard_witness_1, :discard_witness_2, :checked_by, :verified_by, :examiner1, :examiner2, :is_staff1, :is_staff2, :examiner_staff1,:examiner_staff2, :witness_outsider1, :witness_outsider2,:witness_is_staff1, :witness_is_staff2)
      #:code, :category, :unittype, :maxquantity, :minquantity, damages_attributes: [:id, :description,:reported_on,:document_id,:location_id])
    end
end