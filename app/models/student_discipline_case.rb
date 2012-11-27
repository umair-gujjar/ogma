class StudentDisciplineCase < ActiveRecord::Base
  # befores, relationships, validations, before logic, validation logic, 
  #controller searches, variables, lists, relationship checking
  
  before_save :close_if_no_case
  
  belongs_to :staff, :foreign_key => 'reported_by'
  belongs_to :student
  belongs_to :cofile, :foreign_key => 'file_id'
  
  has_many :student_counseling_sessions, :foreign_key => 'case_id', :validate => false#, :dependent => :destroy
  accepts_nested_attributes_for :student_counseling_sessions#, :reject_if => lambda { |a| a[:requested_at].blank? }
  
  
  validates_presence_of :reported_by, :student_id, :status, :infraction_id, :assigned_to
  
  #validate :confimed_date
  
  #def validate_end_date_before_start_date
    #if leavenddate && leavestartdate
      #errors.add(:leavenddate, "Your leave must begin before it ends") if leavenddate < leavestartdate || leavestartdate < DateTime.now
    #end
  #end
  
  def close_if_no_case
    if action_type == "no_case"
      self.status = "Closed"
    end
  end
  
  

    
  # Data Stuff-----------------------------------------------
  INFRACTION = [
         #  Displayed       stored in db
         [ "Merokok", 1  ],
         [ "Ponteng Kelas", 2 ],
         [ "Bergaduh", 3 ],
         [ "Lain Lain", 4 ]
      ]
    
    def status_workflow
    flow = Array.new
    if status == nil
      flow << "New"
    elsif status == "New"
      flow << "Open" 
    elsif status == "Open"
      flow << "Open" << "No Case" << "Refer to BPL" << "Closed" 
    elsif status == "Refer to BPL"
      flow << "Refer to BPL" << "Closed"
    else
    end
    flow
    end

    
   STATUS = [
         #  Displayed       stored in db
         [ "New","New" ],
         [ "Open","Open" ],
         [ "No Case","No Case" ],
         [ "Closed", "Closed" ],
         [ "Refer to BPL", "Refer to BPL" ]
    ]
    
    def reporter_details 
          suid = Array(reported_by)
          exists = Staff.find(:all, :select => "id").map(&:id)
          checker = suid & exists     

          if reported_by == nil
             "" 
           elsif checker == []
             "Staff No Longer Exists" 
          else
            staff.mykad_with_staff_name
          end
    end
    
    def student_name
      suid = Array(student_id)
      suexists = Student.find(:all, :select => "id").map(&:id)
      studentchecker = suid & suexists

        if student_id == nil
          ""
        elsif studentchecker == []
          "Student No Longer Exists"
        else
          " #{student.formatted_mykad_and_student_name}"   
        end 
    end
    
    def file_name
      fileid = Array(file_id)
      doesfileexists = Cofile.find(:all, :select => "id").map(&:id)
      filechecker = fileid & doesfileexists
        if file_id == nil
          ""
        elsif filechecker == []
          "File Does Not Exist"
        else
          " #{cofile.name}"   
        end 
    end
    
    def room_no
      suid = Array(student_id)
      suexists = Tenant.find(:all, :select => "student_id").map(&:student_id)
      roomchecker = suid & suexists
      curroom = Tenant.find(:all, :select => "location_id", :conditions => {:student_id => roomchecker}, :limit => 1).map(&:location_id)
      romname = Location.find(:all, :conditions => {:id => curroom}).map(&:name)
      romcode = Location.find(:all, :conditions => {:id => curroom}).map(&:code)
      

        if student_id == nil
          ""
        elsif roomchecker == []
          "Not Assigned"
        else
          romcode.to_s + " - " + romname.to_s
        end 
    end
end