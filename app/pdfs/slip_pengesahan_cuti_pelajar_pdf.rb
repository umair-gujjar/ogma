class Slip_pengesahan_cuti_pelajarPdf < Prawn::Document
  def initialize(leaveforstudent, view)
    super({top_margin: 50, page_size: 'A4', page_layout: :portrait })
    @leaveforstudent = leaveforstudent
    @view = view

    
    
    font "Times-Roman"
    text "KOLEJ SAINS KESIHATAN BERSEKUTU JOHOR BAHRU", :align => :center, :size => 14, :style => :bold
    move_down 5
    text "SLIP PENGESAHAN CUTI PELAJAR", :align => :center, :size => 14, :style => :bold
    move_down 20
    table1
    
    if @leaveforstudent.student.kins.count > 0
      table2
    end
    table3
      
  end
  
  def table1
    
    data =[["Butiran Cuti Pelajar", ""],
          ["1. Nama Pelajar", ": #{@leaveforstudent.student.formatted_mykad_and_student_name}"],
          ["2. Jenis Cuti", ": #{((DropDown::STUDENTLEAVETYPE.find_all{|disp, value| value == @leaveforstudent.leavetype }).map {|disp, value| disp})[0]}"],
          ["3. Tarikh Mohon Cuti", ": #{@leaveforstudent.requestdate.try(:strftime,"%d - %b - %Y")}"],
          ["4. Sebab", ": #{@leaveforstudent.reason}"],
          ["5. Alamat",": #{@leaveforstudent.address}"],
          ["6. Telefon", ": #{@leaveforstudent.telno }"],
          ["7. Tarikh Cuti Bermula", ": #{@leaveforstudent.leave_startdate.strftime("%a, %d %b %Y")}"],
          ["8. Tarikh Cuti Berakhir", ": #{@leaveforstudent.leave_enddate.strftime("%a, %d %b %Y")}"]]
    
    table(data, :column_widths => [200, 300], :cell_style => { :size => 11})  do
      a = 0
      b = 25
      row(0).font_style = :bold
      row(0).background_color = 'FFE34D'
      while a < b do
        row(a).borders = []
        a += 1
      end
    end
    move_down 10
  end
    
  def table2
    
    data =[["Maklumat Waris", ""]]      
      
    table(data, :column_widths => [200, 300], :cell_style => { :size => 11})  do
      a = 0
      b = 1
      row(0).font_style = :bold
      row(0).background_color = 'FFE34D'
      while a < b do
        row(a).borders = []
        a += 1
      end
    end
            
    @a = []
    @b = []
    @c = []       
                            
    @leaveforstudent.student.kins.map do |x|
      @a << ": #{x.name} "
      @b << ": #{x.display_ktype} "
      @c << ": #{x.phone} "
    end
             
    data2=[]        
    0.upto(@leaveforstudent.student.kins.count-1) do |no|
      data2 << ["Nama","#{@a[no]}"]
      data2 << ["Hubungan","#{@b[no]}"]
      data2 << ["No. Telefon","#{@c[no]}"]
      data2 << ["",""]
    end
    
    table(data2, :column_widths => [200, 300], :cell_style => { :size => 10}) do
      a = 0
      b = 12
      while a < b do
        row(a).borders = []
        a += 1
      end
    end
    move_down 10
  end

  def table3
      
    data =[["Maklumat Kelulusan Cuti", ""],
          ["1. Keputusan Penyelaras Kumpulan", ": #{@leaveforstudent.approved? ? 'Diluluskan' : 'Tidak Diluluskan'}"],
          ["2. Nama Pelulus", ": #{@leaveforstudent.approver_details}"],
          ["3. Tarikh Diluluskan", ": #{@leaveforstudent.approvedate.try(:strftime, '%d %b %Y')}"],
          ["",""],
          ["4. Keputusan Warden", ": #{@leaveforstudent.approved2? ? 'Diluluskan' : 'Tidak Diluluskan'}"],
          ["5. Nama Pelulus", ": #{@leaveforstudent.approver_details2}"],
          ["6. Tarikh Diluluskan", ": #{@leaveforstudent.approvedate2.try(:strftime, '%d %b %Y')}"]]
  
    table(data, :column_widths => [200, 300], :cell_style => { :size => 11})  do
      a = 0
      b = 23
      row(0).font_style = :bold
      row(0).background_color = 'FFE34D'
      while a < b do
        row(a).borders = []
        a += 1
      end
    end
    move_down 10
  end
end