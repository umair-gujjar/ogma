class Staff::StaffAppraisalsController < ApplicationController
  filter_access_to :index, :new, :create, :attribute_check => false
  filter_access_to :show, :edit, :update, :destroy, :appraisal_form, :attribute_check => true
  before_action :set_staff_appraisal, only: [:show, :edit, :update, :destroy] 
  
  def index
    roles = current_user.roles.pluck(:authname)
    @is_admin = roles.include?("administration") || roles.include?("staff_appraisals_module_admin") || roles.include?("staff_appraisals_module_viewer") || roles.include?("staff_appraisals_module_user")
    if @is_admin
      @search = StaffAppraisal.search(params[:q])
    else
      @search = StaffAppraisal.sstaff2(current_user.userable.id).search(params[:q])
    end 
    @staff_appraisals = @search.result
    @staff_appraisals = @staff_appraisals.page(params[:page]||1)
  end
  

  def show
    @staff_appraisal = StaffAppraisal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff_appraisal }
      format.js
    end
  end

  
  def new
    @staff_appraisal = StaffAppraisal.new
    @staff_appraisal.staff_appraisal_skts.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff_appraisal }
    end
  end
  
  def edit
    @staff_appraisal = StaffAppraisal.find(params[:id])
    if params[:job_type] && params[:job_level] 
      @job_type=params[:job_type] #redo_performance
      @job_level=params[:job_level]
    end
  end
  
  def create
    @staff_appraisal = StaffAppraisal.new(staff_appraisal_params)
    respond_to do |format|
      if @staff_appraisal.save
        format.html { redirect_to(staff_staff_appraisal_path(@staff_appraisal), :notice =>t('staff.staff_appraisal.title')+t('actions.created')) }
        format.xml  { render :xml => @staff_appraisal, :status => :created, :location => @staff_appraisal}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff_appraisal.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    #raise params.inspect
    @staff_appraisal = StaffAppraisal.find(params[:id])
    respond_to do |format|
      if @staff_appraisal.update(staff_appraisal_params)
        format.html { redirect_to(staff_staff_appraisal_path(@staff_appraisal), :notice => (t 'staff.staff_appraisal.title')+(t 'actions.updated'))}
        format.xml  { head :ok }
      else
	#msg=StaffAppraisal.messages(a)
	msg=@staff_appraisal.errors.count
        format.html { render :action => "edit", :f => @staff_appraisal} 
	#format.html {redirect_to edit_staff_staff_appraisal_path(@staff_appraisal)}
        #format.html { redirect_to edit_staff_staff_appraisal_path(@staff_appraisal), :notice => msg.to_s+" errors la"}
        format.xml  { render :xml => @staff_appraisal.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @staff_appraisal = StaffAppraisal.find(params[:id])
    respond_to do |format|
      if @staff_appraisal.destroy
        format.html { redirect_to staff_staff_appraisals_url }
        format.json { head :no_content }
      end 
    end
  end
  
  def appraisal_form

    @staff_appraisal = StaffAppraisal.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = Appraisal_formPdf.new(@staff_appraisal, @current_user, view_context)
        send_data pdf.render, filename: "appraisal_form-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_appraisal
      @staff_appraisal = StaffAppraisal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staff_appraisal_params
      params.require(:staff_appraisal).permit(:staff_id, :evaluation_year, :eval1_by, :eval2_by, :is_skt_submit, :skt_submit_on, :is_skt_endorsed, :skt_endorsed_on, :skt_pyd_report, :is_skt_pyd_report_done, :skt_pyd_report_on, :skt_ppp_report, :is_skt_ppp_report_done, :skt_ppp_report_on, :is_submit_for_evaluation, :submit_for_evaluation_on, :g1_questions, :g2_questions, :g3_questions, :e1g1q1, :e1g1q2,:e1g1q3, :e1g1q4, :e1g1q5,:e1g1_total, :e1g1_percent,:e1g2q1, :e1g2q2, :e1g2q3, :e1g2q4, :e1g2_total, :e1g2_percent, :e1g3q1, :e1g3q2, :e1g3q3, :e1g3q4, :e1g3q5, :e1g3_total, :e1g3_percent,:e1g4,:e1g4_percent, :e1_total, :e1_years, :e1_months, :e1_performance, :e1_progress, :is_submit_e2, :submit_e2_on, :e2g1q1, :e2g1q2, :e2g1q3,:e2g1q4, :e2g1q5,:e2g1_total, :e2g1_percent, :e2g2q1, :e2g2q2,:e2g2q3, :e2g2q4, :e2g2_total, :e2g2_percent, :e2g3q1, :e2g3q2, :e2g3q3,:e2g3q4,:e2g3q5, :e2g3_total,:e2g3_percent, :e2g4, :e2g4_percent,:e2_total, :e2_years, :e2_months, :e2_performance, :evaluation_total, :is_complete, :is_completed_on, 
      staff_appraisal_skts_attributes: [:id,:_destroy, :priority, :description, :half, :indicator_desc_quality, :indicator_desc_time, :indicator_desc_quantity, :indicator_desc_quantity, :indicator_desc_cost, :target_quality, :target_time, :target_quantity, :target_cost, :achievement_quality, :achievement_time, :achievement_quantity, :achievement_cost, :progress_quality, :progress_time, :progress_quantity, :progress_cost, :notes_quality, :notes_time, :notes_quantity, :notes_cost, :is_dropped, :dropped_on, :drop_reasons], evactivities_attributes: [:id,:_destroy, :evaldt, :evactivity, :actlevel, :actdt], trainneeds_attributes: [:id,:_destroy, :name, :reason, :confirmedby_id, :evaluation_id])
    end
  
end
