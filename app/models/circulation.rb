class Circulation < ActiveRecord::Base
  belongs_to :document
  belongs_to :staff
   
#---------------------AttachFile------------------------------------------------------------------------
 has_attached_file :action,
                    :url => "/assets/documents/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/documents/:id/:style/:basename.:extension"
 
  validates_attachment_content_type :action, 
                                    :content_type => ['application/pdf','application/txt', 'application/msword',
                                                      'application/msexcel','image/png','image/jpeg','text/plain',
                                                       'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
                                    :storage => :file_system,
                                    :message => "Invalid File Format"                        
  validates_attachment_size :action, :less_than => 5.megabytes
 
end