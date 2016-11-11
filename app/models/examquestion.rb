class Examquestion < ActiveRecord::Base

  belongs_to :creator,  :class_name => 'Staff', :foreign_key => 'creator_id'
  belongs_to :approver, :class_name => 'Staff', :foreign_key => 'approver_id'
  belongs_to :editor,   :class_name => 'Staff', :foreign_key => 'editor_id'
  belongs_to :course, :class_name => 'Programme', :foreign_key => 'programme_id'
  belongs_to :subject,  :class_name => 'Programme', :foreign_key => 'subject_id'
  belongs_to :topic,    :class_name => 'Programme', :foreign_key => 'topic_id'
  has_and_belongs_to_many :exams

  has_many :answerchoices, :dependent => :destroy
  accepts_nested_attributes_for :answerchoices, :allow_destroy => true , :reject_if => lambda { |a| a[:description].blank? }
  has_many :examanswers, :dependent => :destroy
  accepts_nested_attributes_for :examanswers, :allow_destroy => true , :reject_if => lambda { |a| a[:answer_desc].blank? }
  has_many :shortessays, :dependent => :destroy
  accepts_nested_attributes_for :shortessays#, :allow_destroy => true , :reject_if => lambda { |a| a[:subquestion].blank? }
  has_many :booleanchoices, :dependent => :destroy
  accepts_nested_attributes_for :booleanchoices, :allow_destroy => true , :reject_if => lambda { |a| a[:description].blank? }
  has_many :booleananswers, :dependent => :destroy
  accepts_nested_attributes_for :booleananswers, :allow_destroy => true , :reject_if => lambda { |a| a[:answer].blank? }

  attr_accessor :activate, :answermcq

  scope :mcqq, -> { where(questiontype: 'MCQ')}
  scope :meqq, -> { where(questiontype: 'MEQ')}
  scope :seqq, -> { where(questiontype: 'SEQ')}
  scope :acqq, -> { where(questiontype: 'ACQ')}
  scope :osci2q, -> { where(questiontype: 'OSCI')}
  scope :osci3q, -> { where(questiontype: 'OSCII')}
  scope :osceq, -> { where(questiontype: 'OSCE')}
  scope :ospeq, -> { where(questiontype: 'OSPE')}
  scope :vivaq, -> { where(questiontype: 'VIVA')}
  scope :truefalseq, -> { where(questiontype: 'TRUEFALSE')}

  has_attached_file :diagram,
                    :url => "/assets/examquestions/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/examquestions/:id/:style/:basename.:extension",
                    :styles => { :original => "250x300>", :thumbnail => "50x60" } #default size of uploaded image
  validates_attachment_size :diagram, :less_than => 5.megabytes
  validates_attachment_content_type :diagram, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
                    #may require validation

  validates_presence_of :subject_id, :topic_id, :questiontype, :question, :marks, :qstatus, :createdt, :programme_id, :creator_id #17Apr2013,:answer #9Apr2013-compulsory for subject_id
  validates_presence_of :editor_id, :editdt, :if => :status_is_editing?
  validate :approver_must_exist
  
  #has_many :examsubquestions, :dependent => :destroy
  #accepts_nested_attributes_for :examsubquestions, :reject_if => lambda { |a| a[:question].blank? }

  #has_many :exammcqanswers, :dependent => :destroy
  #accepts_nested_attributes_for :exammcqanswers, :reject_if => lambda { |a| a[:answer].blank? }

  before_validation :set_nil_if_not_activate, :set_answer_for_mcq, :set_approvedt_if_approved#, :reset_status_if_approver_is_blank
  
  #before_save :set_answer_for_mcq#, :set_subquestions_if_seq
  
  def status_is_editing?
    qstatus=="Editing"
  end
  
  def approver_must_exist
     if qstatus=="Ready For Approval" && (approver_id.blank? || approver_id.nil?)
        errors.add( I18n.t('exam.examquestion.approver_id'),I18n.t('exam.examquestion.selected_if_readyforapproval'))
        self.qstatus="Editing"
     end
  end
  
  def set_approvedt_if_approved
    if qstatus == "Approved" && (approvedt.blank? || approvedt.nil?)
      self.approvedt = Date.today.strftime('%Y-%m-%d')
    end
  end

  def set_nil_if_not_activate
     #if self.id != nil   
          if questiontype=="MCQ" && activate != "1" 
              self.answerchoices[0].description = "" if self.answerchoices[0]#.id !=nil
              self.answerchoices[1].description = "" if self.answerchoices[1]#.id !=nil
              self.answerchoices[2].description = "" if self.answerchoices[2]#.id !=nil
              self.answerchoices[3].description = "" if self.answerchoices[3]#.id !=nil
          end
      #end
  end
  
  def set_answer_for_mcq
      #if answermcq !=nil 
      if questiontype=="MCQ" 
        self.answer=answermcq.to_s
      end
        #end
  end

  #def set_subquestions_if_seq
    #if self.id == nil && questiontype=="SEQ"
        #self.shortessays[0].item = "a"    #new
        #self.shortessays[1].item = "b"
        #self.shortessays[2].item = "c"
    #end
  #end

  # define scope
  def self.keyword_search(query) 
    subject_ids = Programme.where('code ILIKE(?) or name ILIKE(?)', "%#{query}%", "%#{query}%").pluck(:id)
    where('subject_id IN(?)', subject_ids)
  end

  # whitelist the scope
  def self.ransackable_scopes(auth_object = nil)
    [:keyword_search]
  end

  def question_creator(current_user)
    if current_user.roles.pluck(:authname).include?("administration")
      diploma=Programme.roots.where(course_type: "Diploma").pluck(:name)
      creator_units=diploma+["Diploma Lanjutan", "Pos Basik", "Pengkhususan"]
      creator_ids=Staff.joins(:positions).where('positions.unit IN(?)', creator_units).pluck(:id)
      creator=creator_ids+[current_user.userable_id]
    else
      creator=[current_user.userable_id]
    end
  end
    
  def question_editor(current_user)
    unless programme_id.nil?
      if Programme.where(course_type: 'Commonsubject').pluck(:id).include?(subject_id)
        common_subjects=['Sains Tingkahlaku','Sains Perubatan Asas', 'Komunikasi & Sains Pengurusan', 'Anatomi & Fisiologi', 'Komuniti']
        editors = Position.where(unit: common_subjects).pluck(:staff_id).compact
      elsif Programme.roots.where(course_type: "Diploma").pluck(:name).include?(course.name)
        editors = Position.where(unit: course.name).pluck(:staff_id).compact
      else #must be posbasiks
        posts = Position.where(unit: ["Diploma Lanjutan", "Pos Basik", "Pengkhususan"])
        posbasiks_name = Programme.roots.where(course_type: ["Diploma Lanjutan", "Pos Basik", "Pengkhususan"]).pluck(:name)
        @editors=[]
        posts.each do |post|
          posbasiks_name.each do |pname|
            @editors << post.id if post.tasks_main.include?(pname)
          end
        end
        editors=@editors
      end
      editors << current_user.userable_id if current_user.roles.pluck(:authname).include?("administration")
      editors
    end
    editors
  end
  
  def question_approver #to assign question -> KP
    ###latest finding - as of Mei-Jul/Aug 2013 - approver should be at Ketua Program level ONLY (own programme @ other programme)
    
    role_kp = Role.where(name: 'Programme Manager').pluck(:id) #must have role as Programme Manager
    staff_with_kprole = Login.joins(:roles).where('role_id IN(?)',role_kp).pluck(:staff_id).compact.uniq
    programme_name = Programme.roots.map(&:name)    #must be among Academic Staff 
    approver = Staff.joins(:positions).where('unit IN(?) AND staff_id IN(?)', programme_name, staff_with_kprole).pluck(:staff_id)
    #add Ketua Subjek Asas when subject is a Common Subject
    if Programme.where(course_type: 'Commonsubject').pluck(:id).include?(subject_id)
      common_subjects=['Sains Tingkahlaku','Sains Perubatan Asas', 'Komunikasi & Sains Pengurusan', 'Anatomi & Fisiologi', 'Komuniti']
      commonsubject_posts=Position.where(unit: common_subjects)
      commonsubject_leaders=[]
      commonsubject_posts.each do |csp|
        commonsubject_leaders << csp.staff_id if csp.tasks_main.include?('Ketua Subjek') || csp.tasks_other.include?('Ketua Subjek')
      end
      approver+=commonsubject_leaders.compact
    end
    approver   
  end
  
  
  def self.search2(programmeid)
    if programmeid == '0' #admin 
      @examquestions = Examquestion.all
    elsif programmeid == "1" #KP Pengkhususan
      posbasiks_ids = Programme.roots.where(course_type: ["Diploma Lanjutan", "Pos Basik", "Pengkhususan"]).pluck(:id)
      @examquestions = Examquestion.where(programme_id: posbasiks_ids)
    elsif programmeid == "2" #Common Subject lecturers
      common_subject_ids = Programme.where(course_type: 'Commonsubject').pluck(:id)
      @examquestions = Examquestion.where(subject_id: common_subject_ids )
    else
      subject_ids=Programme.where(id: programmeid).first.descendants.at_depth(2).pluck(:id)
      @examquestions = Examquestion.where(subject_id: subject_ids)
    end
  end
  
  #logic to set editable - ref: Staff Appraisal
  def edit_icon(curr_user)
    is_admin=true  if curr_user.roles.pluck(:authname).include?("administration")
    if qstatus=="New" &&(creator_id==curr_user.userable_id || is_admin)
      "edit.png"
    elsif qstatus=="New" && creator_id!=curr_user.userable_id
      "noedit"
    elsif qstatus=="Submit" && (curr_user.lecturers_programme==programme_id || is_admin)#(curr_user.lecturers_programme.include?(programme_id) || is_admin)
      "edit.png"
    elsif ["Editing", "Re-Edit"].include?(qstatus) && (editor_id==curr_user.userable_id || is_admin)
      "edit.png"
    elsif qstatus=="Re-Edit" && approver_id==curr_user.userable_id
      "noedit"
    elsif ["Ready For Approval", "For Approval"].include?(qstatus) && (creator_id==curr_user.userable_id || editor_id==curr_user.userable_id) && !is_admin
      "noedit"
    elsif  ["Ready For Approval", "For Approval"].include?(qstatus) && (approver_id==curr_user.userable_id || is_admin)
      "edit.png"
    elsif qstatus=="Approved" && (approver_id==curr_user.userable_id || is_admin)
      "edit.png"
    elsif qstatus=="Approved" && approver_id!=curr_user.userable_id
      "noedit"
    end
  end
   
  def render_difficulty
     (DropDown::QLEVEL.find_all{|disp, value| value == difficulty }).map {|disp, value| disp}[0]
  end
   
  def subject_details
     if subject.blank? 
       "None Assigned"
     else 
       subject.subject_list
     end
  end

  def creator_details
    if creator.blank?
       "None Assigned"
     else
       creator.name #mykad_with_staff_name
     end
  end

  def editor_details
    if editor.blank?
      "None Assigned"
    elsif editor_id?
      editor.staff_name_with_position
    else 
      "None Assigned"
    end
  end

  def approver_details
    if approver.blank?
      "None Assigned"
    else
      approver.name
    end
  end

  #10Apr2013
  def usage_frequency
      Examquestion.joins(:exams).where('examquestion_id=?',id).count
  end
  #10Apr2013

  def combine_subquestions
    shortessays2=Shortessay.find(:all, :conditions=>['examquestion_id=?',id])
    subq=[]
    shortessays2.each do |y|
      unless y.subquestion.nil? || y.subquestion.blank?
        subq<< "("+y.item.to_s+") "+y.subquestion+" ("+y.submark.to_s+") ["+y.subanswer.to_s+"]"
      end
    end
    subq.to_s
  end

#   def self.csv(options={})
#     CSV.generate(options) do |csv|
#       csv << column_names
#       all.each do |examquestion|
#         csv << examquestion.attributes.values_at(*column_names)
#       end
#     end
#   end
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
        csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.list').upcase]  #title added ---> refer examanalysis.rb
        csv << [] #blank row added
        csv << ["NO", I18n.t('exam.examquestion.questiontype').upcase, I18n.t('exam.examquestion.question').upcase+" & "+I18n.t('exam.examquestion.answer').upcase, I18n.t('exam.examquestion.marks').upcase, I18n.t('exam.examquestion.category').upcase, I18n.t('exam.examquestion.difficulty').upcase, I18n.t('exam.examquestion.qstatus').upcase, I18n.t('exam.examquestion.creator_id').upcase]

        all.group_by{|x|x.subject.root_id}.each do |prog, examquestions|
          unless prog.blank?
              csv << []
              csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.programme_id')+" : "+ Programme.find(prog).name]
          end
          cnt=0 #question counter per programme
          #-------------------------
          examquestions.group_by{|t|t.subject_details}.sort.each do |subject_details, examquestions| 
              csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.subject_id')+" : "+subject_details, "\'\'", "\'\'", I18n.t('exam.examquestion.total_questions')+" = "+examquestions.count.to_s]

              topic_count=0
              examquestions.group_by{|x|x.topic_id}.sort.each do |topic, allquestions|
                  csv << [] if topic_count > 0     #add blank row when there's more than 1 topic exist per subject
                  csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.topic_id')+" : "+ Programme.find(topic).subject_list, "\'\'", Programme.find(topic).parent.code.to_s+' | '+topic.to_s, I18n.t('exam.examquestion.total_questions')+' = '+allquestions.count.to_s]
                  csv << []
              
                  allquestions.group_by{|t|t.questiontype}.each do |questiontype,questionbytype|  
                      qbytype_count=0
                      questionbytype.each do |q|
                          csv << [] if qbytype_count > 0
                          if q.question.include?('span')==false
                              qtext=ActionView::Base.full_sanitizer.sanitize(q.question, :tags => %w(img br p), :attributes => %w(src style))
                          else
                              qtext=(ActionView::Base.full_sanitizer.sanitize(q.question, :tags => %w(img br p span), :attributes => %w(src style)) ).gsub!("&nbsp;", " ")
                          end
                          csv << [cnt+=1, q.questiontype, qtext, q.marks, q.category.blank? ? "\'\'" : q.category, q.render_difficulty, q.qstatus, q.creator_details] 

                          ######ANSWER - start
                          #qanswer=""
                          #qanswer+="<br><b>#{I18n.t('exam.examquestion.answer')}</b>"
                          csv << []
                          csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.answer').upcase+" : "]
                          
                          #MCQ start
                          if q.questiontype=="MCQ"
                              #qanswer+="<br>"
                              if q.answerchoices.count != 0 && q.answerchoices[0].description!=""
                                  for answerchoice in q.answerchoices.sort_by{|x|x.item}
                                      #qanswer+="#{answerchoice.item}"
                                      #qanswer+=" #{answerchoice.description}<br>"
                                      csv << ["\'\'", "\'\'", answerchoice.item+". "+answerchoice.description]
                                  end  
                                  #qanswer+="<br>"
                                  csv << []
                              end
                              for examanswer in q.examanswers.sort_by{|y|y.item}
                                  #qanswer+="#{examanswer.item}"
                                  #qanswer+=" #{examanswer.answer_desc}<br>"
                                  csv << ["\'\'", "\'\'", examanswer.item+". "+examanswer.answer_desc]
                              end
                          
                          elsif q.questiontype=="SEQ" 
                              #$$$$$$$$$$$$$$$$
                              for shortessay in q.shortessays.sort_by{|x|x.item}	
                                  #qanswer+="<br>"
                                  csv << []
                                  #qanswer+="<u>#{I18n.t('exam.examquestion.subquestion')} #{shortessay.item} : </u><br>"
                                  #qanswer+="#{shortessay.subquestion} (#{shortessay.submark.to_s} #{I18n.t('exam.examquestion.marks')})<br>"
                                  csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.subquestion')+" "+shortessay.item+" : "]
                                  csv << ["\'\'", "\'\'", shortessay.subquestion+" ("+shortessay.submark.to_s+I18n.t('exam.examquestion.marks')+")"]
                                  csv << []
                                  #qanswer+="<u>#{I18n.t('exam.examquestion.keyword')} #{shortessay.item} :</u><br>"
                                  #qanswer+="#{shortessay.keyword}<br>"
                                  csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.keyword')+" "+shortessay.item+" : "]
                                  csv << ["\'\'", "\'\'", shortessay.keyword]
                                  csv << []

                                  #qanswer+="<u>#{I18n.t('exam.examquestion.subanswer')} #{shortessay.item} :</u><br>"
                                  csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.subanswer')+" "+shortessay.item+" : "]
                                  ###-----------------
                                  if shortessay.subanswer.include?('span')==false
                                      #subanswer=shortessay.subanswer
                                      subanswer=ActionView::Base.full_sanitizer.sanitize(shortessay.subanswer, :tags => %w(img br p), :attributes => %w(src style))
                                  else
                                      #subanswer=@view.texteditor_content(shortessay.subanswer)
                                      subanswer=(ActionView::Base.full_sanitizer.sanitize(shortessay.subanswer, :tags => %w(img br p span), :attributes => %w(src style)) ).gsub!("&nbsp;", " ")
                                  end
                                  ###----------------
                                  #qanswer+="#{subanswer}"
                                  csv << ["\'\'", "\'\'", subanswer]
                              end
                              csv << []
                              #$$$$$$$$$$$$$$$$
                          
                          elsif q.questiontype=="TRUEFALSE"
                              #***********************
                              #qanswer+="<br><u>#{I18n.t('exam.examquestion.booleanchoices')}</u><br>"
                              csv << []
                              csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.booleanchoices')]
                              csv << []
                              for booleanchoice in q.booleanchoices.sort_by{|x|x.item}
                                  #qanswer+="#{booleanchoice.item}. "
                                  #qanswer+="#{booleanchoice.description}<br>"
                                  csv << ["\'\'", "\'\'", booleanchoice.item+". "+booleanchoice.description]
                              end
                              #qanswer+="<u>#{I18n.t( 'exam.examquestion.booleananswers')}</u><br>"
                              csv << []
                              csv << ["\'\'", "\'\'", I18n.t( 'exam.examquestion.booleananswers')]
                              csv << []
                              for booleananswer in q.booleananswers.sort_by{|y|y.item}
                                  #qanswer+="#{booleananswer.item}. "
                                  #qanswer+="#{I18n.t('exam.examquestion.true1') if booleananswer.answer==true}"
                                  #qanswer+="#{I18n.t('exam.examquestion.false1') if booleananswer.answer==false}"
                                  if booleananswer.answer==true
                                      ans=I18n.t('exam.examquestion.true1') 
                                  else
                                      ans=I18n.t('exam.examquestion.false1')
                                  end
                                  #qanswer+="<br>"
                                  csv << ["\'\'", "\'\'", booleananswer.item+". "+ans]
                                  #csv << []
                              end
                              #***********************
                          end #endof if mcq etc



                          #MCQ final ANSWER
                          if q.questiontype=="MCQ"
                              #qanswer+="<u>#{I18n.t('exam.examquestion.answermcq')} : #{q.answer.to_s}</u>"
                              csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.answermcq')+" : "+q.answer.to_s]
                          end
                          #answer field for other than MCQ & SEQ 
                          if !(q.questiontype=="MCQ" || q.questiontype=="SEQ")
                              #qanswer+="<br>#{I18n.t('exam.examquestion.answer')} : #{q.answer  }"  
                              csv << ["\'\'", "\'\'", I18n.t('exam.examquestion.answer')+" : "+q.answer]
                              csv << []
                          end
                          ######ANSWER - end

                          qbytype_count+=1
                      end #endof questionbytype
                  end #endof allquestions.group_by
                  topic_count+=1
              end
          end 
          #-------------------------
        end #endof all.group_by....

      end #endof CSV.generate
  end

end

# == Schema Information
#
# Table name: examquestions
#
#  accuracy_component    :boolean
#  accuracy_construct    :boolean
#  accuracy_topic        :boolean
#  answer                :text
#  approvedt             :date
#  approver_id           :integer
#  bplreserve            :boolean
#  bplsent               :boolean
#  bplsentdt             :date
#  category              :string(255)
#  conform_curriculum    :boolean
#  conform_opportunity   :boolean
#  conform_specification :boolean
#  construct             :string(255)
#  created_at            :datetime
#  createdt              :date
#  creator_id            :integer
#  diagram_caption       :string(255)
#  diagram_content_type  :string(255)
#  diagram_file_name     :string(255)
#  diagram_file_size     :integer
#  diagram_updated_at    :datetime
#  difficulty            :string(255)
#  editdt                :date
#  editor_id             :integer
#  fit_difficulty        :boolean
#  fit_fairness          :boolean
#  fit_important         :boolean
#  id                    :integer          not null, primary key
#  marks                 :decimal(, )
#  programme_id          :integer
#  qkeyword              :string(255)
#  qstatus               :string(255)
#  question              :text
#  questiontype          :string(255)
#  statusremark          :text
#  subject_id            :integer
#  topic_id              :integer
#  updated_at            :datetime
#
