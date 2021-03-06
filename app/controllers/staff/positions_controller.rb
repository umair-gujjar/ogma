class Staff::PositionsController < ApplicationController
  #filter_access_to :all
  filter_access_to :index, :new, :create, :organisation_chart, :attribute_check => false
  filter_access_to :show, :edit, :update, :maklumat_perjawatan, :maklumat_perjawatan_excel, :destroy, :attribute_check => true
  before_action :set_position, only: [:show, :edit, :update, :destroy]
  
  def index
    @positions = Position.order("combo_code ASC")#.where("ancestry_depth < ?", 2)
    render :layout => 'basic'
  end
  
  def new
    @position=Position.new(:parent_id => params[:parent_id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @position }
    end
  end
  
  def create
    @position=Position.new(position_params)
    respond_to do |format|
      if @position.save
        format.html { redirect_to(staff_position_path(@position)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @position.update_attributes(position_params)
        flash[:notice] = (t 'position.name')+(t 'actions.updated')
        format.html { redirect_to(staff_position_path(@position)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @position = Position.find(params[:id])
    @position.destroy

    respond_to do |format|
      format.html { redirect_to("http://#{request.host}:3000/positions") }
      format.xml  { head :ok }
    end
  end
  
  def maklumat_perjawatan
    @positions=[]
    #BELOW SAME AS : unless position.staffgrade.blank? && position.postinfo_id.blank?    #must include those w/o butiran - to match with Maklumat Perjawatan
    #@positions_raw = Position.where('staffgrade_id IS NOT NULL AND staff_id IN(?) AND name!=?', Staff.all.map(&:id), 'ICMS Vendor Admin') 
    @positions_raw = Position.where('staffgrade_id IS NOT NULL AND name!=?', 'ICMS Vendor Admin') 
    @positions_raw.group_by{|x|x.staffgrade.name.scan(/[a-zA-Z]+|[0-9]+/)[1].to_i}.sort.reverse!.each do |staffgrade2, positions_of_grade_no|
       positions_of_grade_no.group_by{|x|x.staffgrade.name.scan(/[a-zA-Z]+|[0-9]+/)[0]}.sort.reverse!.each do |staffgrade, positions_by_grade|
         positions_by_grade_w_butiran=[]
         positions_by_grade_wo_butiran=[]
         positions_by_grade.each do |position|
           unless position.postinfo_id.blank? 
             positions_by_grade_w_butiran<< position
           else 
             positions_by_grade_wo_butiran<< position 
           end
         end 
         @positions.concat(positions_by_grade_w_butiran.sort_by{|x|[x.staffgrade_id, -(x.postinfo.details[0,3].to_i), x.combo_code]})
         #@positions2.concat(positions_by_grade_w_butiran.sort_by{|x|[x.staffgrade_id, x.postinfo_id, x.combo_code]})
         #@positions2.concat(positions_by_grade_w_butiran.sort_by{|x|[x.staffgrade_id, x.postinfo_id, x.staff.name]})
         @positions.concat(positions_by_grade_wo_butiran.sort_by{|x|[x.staffgrade_id, x.combo_code]})
         #@positions2.concat(positions_by_grade_wo_butiran.sort_by{|x|[x.staffgrade_id, x.staff.name]})
       end
    end
    respond_to do |format|
      format.pdf do
        pdf = Maklumat_perjawatanPdf.new(@positions, view_context)
        send_data pdf.render, filename: "maklumat_perjawatan-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  #Excel - Menu : Staff | Reports | Position Informations
  def maklumat_perjawatan_excel
    @positions_raw = Position.where('staffgrade_id IS NOT NULL AND name!=?', 'ICMS Vendor Admin') 
    respond_to do |format|
      format.html
      format.csv { send_data @positions_raw.to_csv}
      format.xls { send_data @positions_raw.to_csv(col_sep: "\t") } 
    end
  end
  
  #static PDF for Index
  def organisation_chart
    @positions = Position.order("combo_code ASC")
    @pa=Position.where('tasks_main ILIKE(?) or tasks_other ILIKE(?)', '%PA Pengarah%', '%PA Pengarah%')
    respond_to do |format|
      format.pdf do
        pdf = Organisation_chartPdf.new(@positions, @pa, view_context)
        send_data pdf.render, filename: "organisation_chart-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_position
      @position = Position.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def position_params
      params.require(:position).permit(:parent_id,:code, :combo_code, :name, :unit, :tasks_main, :tasks_other, :staffgrade_id, :staff_id, :staff_id2, :is_acting, :ancestry, :ancestry_depth, :postinfo_id, :status)
    end
end
