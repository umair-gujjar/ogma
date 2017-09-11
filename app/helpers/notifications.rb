module Notifications

 #use id if you do not require object relations
 def current_staff_id
  if is_staff?
   current_user.userable_id
  end
 end

 def current_staff
  if is_staff?
   current_user.userable
  end
 end
 
 def current_student_id
   if is_student?
     current_user.userable_id
   end
 end
 
 def current_student
   if is_student?
     current_user.userable
   end
 end

 def leave_notifications
  my_first_level_approval  = Leaveforstaff.where(approval1_id: current_staff_id).where(approval1: nil).count
  my_second_level_approval = Leaveforstaff.where(approval1: true).where(approval2_id: current_staff_id).where(approver2: nil).count
  my_first_level_approval + my_second_level_approval
 end

 def my_leave_approvals
  Leaveforstaff.where(staff_id: current_staff_id).where(approval1: true).where(approval1: true).where("leavestartdate > ?", Date.today).pluck(:id, :leavestartdate)
 end

 def skts_endorse_ready
  StaffAppraisal.where(eval1_by: current_staff_id).where(is_skt_submit: true).where(is_skt_endorsed: nil).count
 end

 def skt_review_ready
  StaffAppraisal.where(eval1_by: current_staff_id).where(is_skt_pyd_report_done: true).where(skt_ppp_report: nil).count
 end

 def appraisal_requests
  me_as_ppp = StaffAppraisal.where(eval1_by: current_staff_id).where(is_submit_for_evaluation: true).where(is_submit_e2: nil).count
  me_as_ppk = StaffAppraisal.where(eval2_by: current_staff_id).where(is_submit_e2: true).where(is_complete: nil).count
  me_as_ppp + me_as_ppk
 end

 def late_require_approval
   StaffAttendance.find_approvelate(current_user).where(is_approved: nil).where.not(reason: nil).count
 end
 
 def early_require_approval
   StaffAttendance.find_approveearly(current_user).where(is_approved: nil).where.not(reason: nil).count
 end

 def late_need_a_reason
  if current_staff && current_staff.positions.exists?
   StaffAttendance.where(trigger: true).where(reason: nil).where(thumb_id: current_staff.thumb_id).count
  else
    0
  end
 end
 
 def fingerprint_require_approval
   Fingerprint.find_approvestatement(current_user).where(is_approved: nil).count
 end

 def travel_request_needs_approval
  TravelRequest.where(hod_id: current_staff_id).where(is_submitted: true).where(hod_accept: [nil, false]).count
 end

 def your_travel_approved
  TravelRequest.where(staff_id: current_staff_id).where(hod_accept: true).where('depart_at > ? AND depart_at <?', Date.today - 2.month, Date.today).pluck(:id, :depart_at)
 end
 
 def travel_claims_for_checking
   if current_user.roles.pluck(:authname).include?("finance_unit")
     TravelClaim.where(is_submitted: true).where(is_returned: [nil, false]).where(is_checked: [nil, false]).count
   else
     0
   end
 end
 
 def travel_claims_returned
   TravelClaim.where(staff_id: current_staff_id).where(is_submitted: true).where(is_returned: true).where(is_checked: false).count
 end
 
 def travel_claims_for_approval
   TravelClaim.where(is_submitted: true).where(is_checked: true).where(approved_by: current_staff_id).where(is_approved: [nil, false]).count
 end

 def asset_with_defects
  AssetDefect.where(is_processed: nil).where(processed_by: nil).where('decision_by !=?', current_staff_id ).count
 end

 def defect_actions_for_approval
  AssetDefect.where(decision_by: current_staff_id).where(is_processed: true).where(decision: nil).count
 end

 def student_notification_of_leave
   Leaveforstudent.where(student_id: current_user.userable_id, approved: true, approved2: true).where('leave_startdate >=?', Date.tomorrow).order(leave_startdate: :asc).pluck(:leave_startdate) unless is_staff?
 end
 
 def staff_notifications_of_student_leave
   if is_staff?
     if current_user.roles.pluck(:id).include?(2) #administration
        a = Leaveforstudent.where("studentsubmit =? AND approved IS ? AND leave_startdate >=?", true, nil, Date.tomorrow)
        b = Leaveforstudent.where("studentsubmit =? AND approved2 IS ? AND leave_startdate >=?", true, nil, Date.tomorrow)
        leaveforstudents = (a + b).uniq
     else
       if current_user.roles.pluck(:id).include?(7) #warden
         if current_staff.positions.first.tasks_main.include?('Penyelaras Kumpulan')
           pending_applications = Leaveforstudent.pending_coordinator.map(&:id)
           leaveforstudents = Leaveforstudent.where('student_id IN(?) and id IN(?) and leave_startdate >=?', current_user.under_my_supervision, pending_applications, Date.tomorrow)  
         else #warden, but not a coordinator
           pending_applications = Leaveforstudent.pending_warden.map(&:id)
           leaveforstudents = Leaveforstudent.where('id IN(?) and leave_startdate >=?', pending_applications, Date.tomorrow)  
         end
       else 
         if current_user.roles.pluck(:id).include?(14) #lecturer
           pending_applications = Leaveforstudent.pending_coordinator.map(&:id)
           leaveforstudents = Leaveforstudent.where('student_id IN(?) and id IN(?) and leave_startdate >=?', current_user.under_my_supervision, pending_applications, Date.tomorrow)  
         end
       end
     end
   end
   leaveforstudents.count if leaveforstudents
 end 
 
 def ks_student_discipline
   StudentDisciplineCase.where('assigned_to=? AND assigned2_to is null', current_staff_id).where.not(status: 'Closed').count
 end
 
 def tphep_mentor_counselor_student_discipline
   StudentDisciplineCase.where('assigned2_to=? AND action is null', current_staff_id).where.not(status: 'Closed').count
 end
 
 def comandant_student_discipline
   StudentDisciplineCase.where(comandant_id: current_staff_id).where.not(status: 'Closed').count
 end
 
 def cc1staff_document
   #amsas only (creator --> Pengarah/Komandan..)
   Document.where(cc1staff_id: current_staff_id).where(cc2closed: [nil, false]).where(closed: [nil, false]).count
 end
 
 def recipient_document
   doc_circulates=Circulation.where(staff_id: current_staff_id).where(action_closed: [nil, false]).pluck(:document_id)
   if current_user.college.code=='amsas'
     Document.where(id: doc_circulates).where(cc2closed: true).where(closed: [nil, false]).count
   else
     Document.where(id: doc_circulates).where(cc1closed: true).where(closed: [nil, false]).count
   end
 end
 
 def checker_instructor_appraisal
   InstructorAppraisal.where(qc_sent: true).where(check_qc: current_staff_id).where(checked: [nil, false]).count
 end
 
 def owner_instructor_appraisal
   InstructorAppraisal.where(qc_sent: true).where(staff_id: current_staff_id).where(checked: true).count
 end
 
 def approver_booking_facility
   Bookingfacility.where(approver_id: current_staff_id).where(approval: [nil, false]).where('start_date >=?', Date.today).count
 end
 
 def officer_booking_facility
   # NOTE : require 1)staff to be the administor of location & 2)roles - 'facilities_administrator'
   # NOTE : 'approver_id2' - not define by 1st approver, but selection provided includes location's administrator & access granted by 'facilities administor' role (refer _tab_reservation_edit.html.haml)
   location_ids=Location.where(staffadmin_id: current_staff_id).pluck(:id)
   if current_user.roles.pluck(:authname).include?('facilities_administrator')
     Bookingfacility.where(location_id: location_ids).where(approval: true, approval2: [nil, false]).where('start_date >=?', Date.today).count
   else
     0
   end
 end
 
 def applicant_booking_facility
   Bookingfacility.where(staff_id: current_staff_id).where(approval: true).where(approval: true).where('start_date >=?', Date.today).count
 end
 
 #a)login as dev - display all visitor (late marine docs)
 def visitor_late_marine_docs
   if is_developer?
     Librarytransaction.marine_docs_transactions.where(returned: [false, nil]).where('returnduedate <?', Date.today.yesterday).count
   else
     0
   end
 end
 
 #1)login as librarian/admin/dev - display all staffs late books
 def librarian_staff_late_library_books
   if is_librarian? || is_admin? || is_developer?
     Librarytransaction.where(ru_staff: true).where(returned: [nil, false]).where.not(accession_id: nil).where('returnduedate <?', Date.today).count
   else
     0
   end
 end
 
 #2)login as librarian/admin/dev - display all students late books
 def librarian_student_late_library_books
   if is_librarian? || is_admin? || is_developer?
     Librarytransaction.where(ru_staff: false).where(returned: [nil, false]).where.not(accession_id: nil).where('returnduedate <?', Date.today).count
   else
     0
   end
 end
 
 #3)login as librarian/admin/dev - display own late books
 def borrower_librarian_late_library_books
   if is_librarian? || is_admin? || is_developer?
     Librarytransaction.where(staff_id: current_staff_id).where(returned: [nil, false]).where.not(accession_id: nil).where('returnduedate <?', Date.today).count
   else
     0
   end
 end
 
 #4)login as other staffs - display own late books (no links)
 def borrower_staff_late_library_books
   if is_librarian? || is_admin? || is_developer?
     0
   else
     Librarytransaction.where(staff_id: current_staff_id).where(returned: [nil, false]).where.not(accession_id: nil).where('returnduedate <?', Date.today).count
   end
 end
 
 #5)login as student - display own late books (no links)
  def borrower_student_late_library_books
    if current_student_id!=nil
      Librarytransaction.where(student_id: current_student_id).where(returned: [nil, false]).where.not(accession_id: nil).where('returnduedate <?', Date.today).count
    else
      0
    end
  end
  
  def reserver_book_now_available
    acc_success_reservation=[]
    accs_with_reservations=Accession.where(id: Accession.existing_reservations)
    accs_with_reservations.each do |acc|
      loan=Librarytransaction.where(accession_id: acc.id).last
      if loan.returned==true                                                                                                                                                  #ready for new loan
        potential_borrower=Accession.find(acc.id).reservations["0"]["reserved_by"]                                                               #user_id
        if current_user.id==potential_borrower.to_i
          acc_success_reservation << acc.id
	end
      end
    end
    if acc_success_reservation.count > 0
      acc_success_reservation.count
    else
      0
    end
  end

  def tenancy_admin_staff_late_keys_return
    location_ids=Location.where(staffadmin_id: current_staff_id).pluck(:id)
    Tenant.where(location_id: location_ids).where('keyexpectedreturn <? AND keyreturned is null', Date.today).where('staff_id is not null').count
  end
   
  def tenancy_admin_student_late_keys_return
    location_ids=Location.where(staffadmin_id: current_staff_id).pluck(:id)
    Tenant.where(location_id: location_ids).where('keyexpectedreturn <? AND keyreturned is null', Date.today).where('student_id is not null').count
  end
  
  def tenant_staff_late_keys_return
    if current_staff_id!=nil
      Tenant.where(staff_id: current_staff_id).where('keyexpectedreturn <? AND keyreturned is null', Date.today).count
    else
      0
    end
  end

  def tenant_student_late_keys_return
    if current_student_id!=nil
      Tenant.where(student_id: current_student_id).where('keyexpectedreturn <? AND keyreturned is null', Date.today).count
    else
      0
    end
  end
  
  def approver_weeklytimetable
    Weeklytimetable.where(is_submitted: true).where(endorsed_by: current_staff_id).where(hod_approved: [nil, false]).count #where(startdate > Date.today).count
  end
  
  def creator_approved_weeklytimetable 
    Weeklytimetable.where(prepared_by: current_staff_id).where(hod_approved: true).count #where(startdate > Date.today).count
  end
  
  def creator_rejected_weeklytimetable 
    Weeklytimetable.where(prepared_by: current_staff_id).where(hod_rejected: true).count #where(startdate > Date.today).count
  end
  
  def lecturer_approved_personalize_weeklytimetable
    complete_approval=0
    all=Weeklytimetable.joins(:weeklytimetable_details).where('weeklytimetable_details.lecturer_id=?', current_staff_id) #where(startdate > Date.today)
    all.group_by(&:startdate).each do |sdate, a2|
      a=all.where('startdate=?', sdate)
      b=all.where('startdate=?',sdate).where('hod_approved=?', true)
      complete_approval+=1 if a.count==b.count
    end
    complete_approval
  end
  
  def lecturer_rejected_lesson_plan
    LessonPlan.where(lecturer: current_staff_id).where(is_submitted: [nil, false]).where(hod_rejected: true).count
  end
  
  def lecturer_approved_lesson_plan
    LessonPlan.where(lecturer: current_staff_id).where(is_submitted: true).where(hod_approved: true).where(report_submit: [nil, false]).count
  end
  
  def endorser_lesson_plan
    LessonPlan.where(endorsed_by: current_staff_id).where(is_submitted: true).where(hod_approved: [nil, false]).count
  end
  
  def endorser_lesson_report
    LessonPlan.where(endorsed_by: current_staff_id).where(report_submit: true).where(report_endorsed: [nil, false]).count
  end
  
  def lecturer_approved_lesson_report
    #temp - keep NOTIFICATION 4 report review completion for 30 days
    LessonPlan.where(lecturer: current_staff_id).where(report_submit: true).where(report_endorsed: true).where('report_endorsed_on <?', Date.today+30.days).count
  end
  
  def editors_submitted_examquestion
    if current_user.college.code=='amsas'
      Examquestion.where(qstatus: 'Submit').where(college_id: College.where(code: 'amsas').first.id).where(programme_id: current_user.editors_programme).count
    elsif current_user.college.code=='kskbjb'
      Examquestion.where(qstatus: 'Submit').where(college_id: College.where(code: 'kskbjb').first.id).where(programme_id: current_user.lecturers_programme).count
    end
  end
  
  def editors_pending_submission_for_approval
    Examquestion.where(qstatus: 'Editing').where(editor_id: current_staff_id).count #applicable to both colleges
  end
  
  def approver_submitted_examquestion
    Examquestion.where(qstatus: ['Ready For Approval', 'For Approval']).where(approver_id: current_staff_id).count #applicable to both colleges
  end
  
  def editors_rejected_examquestion
    Examquestion.where(qstatus: 'Re-Edit').where(editor_id: current_staff_id).count #applicable to both colleges
  end
  
  def creator_approved_examquestions
    Examquestion.where(qstatus: 'Approved').where(creator_id: current_staff_id).count
  end
  
  #all colleges
  def approved_ptdos
    Ptdo.where(unit_approve: true).where(dept_approve: true).where(final_approve: true).where(staff_id: current_staff_id).where(trainee_report: nil).count
  end
  #all colleges
  def final_approval_ptdos 
    if current_staff && current_staff.positions.exists?
      Ptdo.where(unit_approve: true).where(dept_approve: true).where(final_approve: [nil, false]).where(staff_id: current_user.director_subordinates).count
    else
      0
      end
  end
  
  #kskbjb only TODO - check below againts kskbjb data
  #programme manager - user.unit_members (NOTE - unit approval - auto approved for lecturers)
  #administration staff (Timbalan Pengarah) - user.admin_subordinates
  def dept_approval_ptdos
    if current_staff && current_staff.positions.exists?
      Ptdo.where(unit_approve: true).where(dept_approve: [nil, false]).where(staff_id: current_user.unit_members+current_user.admin_subordinates).count
    else
      0
    end
  end
  #unit leader - user.unit_members
  def unit_approval_ptdos
    Ptdo.where(unit_approve: [nil, false]).where(staff_id: current_user.unit_members).count
  end
  
end


=begin
<!-- Notification on Asset Defect -->

	<!-- Notification on Losses -->
	<% permitted_to? :manage, :assets do %>
	<%# if Login.current_login.staff.position.code == "1" %>
	<% loss_require_endorse = AssetLoss.count(:all, :conditions => ['is_submit_to_hod = ? AND endorsed_on IS ?', true, nil ]) %>
	<% if loss_require_endorse > 0 %>
		<%= link_to "#{loss_require_endorse} Asset Losses require verifying", { :controller => "asset_losses", :action => "index" } %><br/>
	<% end %>
	<%# end -%>
	<% end %>


	<!-- Notification on Asset Disposal -->
	<% disposal_require_verify = AssetDisposal.count(:all, :conditions => ['is_checked = ? AND is_verified = ? AND verified_by =?', true, true, Login.current_login.staff_id ]) %>
	<% if disposal_require_verify > 0 %>
		<%= link_to "#{disposal_require_verify} Asset Disposal require verifying", { :controller => "asset_disposals", :action => "index" } %><br/>
	<% end %>


	<!--Notification for Asset Loan-->

<% unless Login.current_login.staff.blank? %>
	<%#****special case for PA Pengarah%****%>
	<% if Login.current_login.staff.id != 101 %>
	<%#**************************************%>

	<% unless Login.current_login.staff.position.blank?  %><!--15Jul2013-added-->
	<%#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%><!--15Jul2013-added-->
	<!--25Apr2013-check if ANY OF logged-in unit members of DEPT/UNIT same as loaned_by(asset owner); HAVE request of asset loan that still pending-->
	<% hods = [6,7,8,9,10,11,12,13,14,15,16,17,18,19,25,26,27,28,29,30,31] %>
	<% logged_login_positionid=Login.current_login.staff.position.id %>
	<% assetloanrequest2=[]%>
	<% unless hods.include?(logged_login_positionid)%><!--NOT HOD-->
		<% unit_members=[]%>
		<% if current_login.staff.position.is_root? %>
		<% else %>
			<% superior = Position.find(:first,:conditions=>['staff_id=?',current_login.staff_id]).parent.staff_id %>
	  	<% end %>
		<% subordinates = Position.find(:first,:conditions=>['staff_id=?',current_login.staff_id]).siblings %>
	  	<% unit_members << superior if superior != nil %>
		<% subordinates.each do |x| %>
			<% unit_members << x.staff_id if x.staff_id !=nil %>
		<% end %><!--
		<%#=current_login.staff_id%>~
		<%#=unit_members %>-->

		<% 0.upto(unit_members.count-1) do |index|%>
			<% assetloanrequest3 = AssetLoan.count(:all, :conditions => ['loaned_by = ? AND is_approved IS NULL', unit_members[index]])%>
			<% if assetloanrequest3 > 0 %>
				<% assetloanrequest2 << assetloanrequest3 %>
			<% end %>
		<% end %>
		<% assetloanrequest2[0]=0 if assetloanrequest2[0].blank? %>
	<% else %>
		<% assetloanrequest2[0]=0%>
	<% end %>

	<!--25Apr2013-check if ANY OF logged-in unit members of DEPT/UNIT same as loaned_by(asset owner); HAVE request of asset loan that still pending-->

	<!--25Apr2013-to notify user for not yet return on-loan asset on due date (expected_on)-->
	<% assetloan_due = AssetLoan.count(:all, :conditions =>['is_approved IS true AND is_returned IS NULL AND staff_id=? AND expected_on<=?',Login.current_login.staff_id,Date.today])
	%>
	<% if assetloan_due > 0 %>
		<%= link_to "#{assetloan_due} Asset on loan due/overdue", { :controller => "asset_loans", :action => "index" } %><br/>
	<% end %>
	<!--25Apr2013-to notify user for not yet return on-loan asset on due date (expected_on)-->

	<!--25Apr2013-asset loan request for processing-->
	<% assetloanrequest = AssetLoan.count(:all, :conditions => ['loaned_by = ? AND is_approved IS NULL', Login.current_login.staff_id]) %>
	<% if assetloanrequest > 0 %>
		<%#= link_to "#{assetloanrequest} Asset Loan requests for approval", { :controller => "asset_loans", :action => "index" } %><br/>
	<% end %>
	<% if assetloanrequest2[0] > 0 && assetloanrequest==0 %>
	<!--assetloanrequest giving 0, when logged-in as OTHER unit member of loaned_by's unit/dept-->
		<%#= link_to "#{assetloanrequest2} Asset Loan requests for approval", { :controller => "asset_loans", :action => "index" } %><br/>
	<% end %>
	<!--25Apr2013-asset loan request for processing-->

	<!--25Apr2013-notify HOD on approval of asset loan regardless of loantype (internal or external) -->
	<% assetnotify_hod = AssetLoan.count(:all, :conditions=>['is_approved IS true AND is_returned IS NOT true AND hod=?',Login.current_login.staff_id]) %>
	<% if assetnotify_hod > 0 %>
		<% if Login.current_login.staff.position.root %>
			<%= link_to "#{assetnotify_hod} Asset Loan requests require your final approval", { :controller => "asset_loans", :action => "index" } %><br/>
		<% else %>
			<%= link_to "#{assetnotify_hod} Asset Loan requests approved for your information", { :controller => "asset_loans", :action => "index" } %><br/>
		<% end %>
	<% end %>
	<!--25Apr2013-notify HOD on approval of asset loan regardless of loantype (internal or external) -->

	<%#=AssetLoan.count(:all, :conditions=>['is_approved IS true AND is_returned IS NOT true AND hod=?',Login.current_login.staff_id])%><%#=current_login.staff_id%>


<% end %><!--end for unless Login.current_login.staff.blank?-->
	<%#****special case for PA Pengarah%****%>

	<% end %><!--15Jul2013-added-->
	<%#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%><!--15Jul2013-added-->

	<% end %>
	<%#**************************************%>


=end
