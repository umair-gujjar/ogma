class Appraisal_formPdf < Prawn::Document
  def initialize(staff_appraisal, view)
    super({top_margin: 50, page_size: 'A4', page_layout: :portrait })
    @staff_appraisals = staff_appraisal
    @view = view
    font "Times-Roman"
    text "BORANG J.P.A. (Prestasi) ", :align => :right, :size => 12, :style => :bold
    text "SULIT", :align => :left, :size => 12
    text "No. K.P", :align => :right, :size => 12, :style => :bold
    move_down 10
    text "KERAJAAN MALAYSIA", :align => :center, :size => 12, :style => :bold   
    move_down 10
    text "LAPORAN PENILAIAN PRESTASI", :align => :center, :size => 12, :style => :bold    
    text "PEGAWAI KUMPULAN SOKONGAN (1)", :align => :center, :size => 12, :style => :bold 
    text "Tahun ", :align => :center, :size => 10, :style => :bold 
    move_down 10
    tajuk1
    tajuk2
    jawatan
   
  end
  
  def tajuk1
    data = [["PERINGATAN"],
           ["Pegawai Penilai (PP) iaitu Pegawai Penilai Pertama (PPP) dan Pegawai Penilai Kedua (PPK) serta Pegawai Yang Dinilai (PYD) hendaklah 
             memberi perhatian kepada perkara-perkara berikut sebelum dan semasa membuat penilaian:" ]]
   
    table(data , :column_widths => [400], :cell_style => { :size => 10}) do
     row(0).borders = [:left, :right, :top]
     row(1).borders = [:left, :right]
     row(0).font_style = :bold
     row(0).background_color = 'FFE34D'

    end 
    
    data1 = [['	i.', "PYD hendaklah melengkapkan maklumat di Bahagian I di bawah dan Bahagian I dalam borang 
      Sasaran Kerja Tahunan (SKT) seperti di Lampiran 'A' pada awal tahun;"],
      ["ii.","PYD hendaklah melengkapkan Bahagian II manakala PP hendaklah melengkapkan Bahagian III hingga Bahagian IX pada akhir tahun penilaian;"],
      ["iii.", "PYD dan PP hendaklah merujuk Panduan Pelaksanaan Sistem Penilaian Prestasi Anggota Perkhidmatan Awam Malaysia (Tahun 2002) 
        sekiranya memerlukan keterangan lanjut semasa mengisi Borang Laporan Penilaian Prestasi Tahunan (LNPT) dan membuat penilaian;"],
        ["	iv.", "PP hendaklah menggunakan Skala Penilaian Prestasi seperti di Lampiran 'B'; dan"],
        ["v.", "PPP hendaklah memaklumkan kepada PYD langkah-langkah meningkatkan prestasi/kemajuan kerjaya yang perlu dilakukan 
          sebelum menandatangani di ruangan Bahagian VIII."]]
      
          table1(data , :column_widths => [30,370], :cell_style => { :size => 10}) do
           row(0).borders = [:left, :right]
           row(1).borders = [:left, :right]
           row(2).borders = [:left, :right]
           row(3).borders = [:left, :right]
           row(4).borders = [:left, :right, :buttom]
           row(0).background_color = 'FFE34D'
      end
      move_down 20
  end
  
  def bahagian1
    
    text "BAHAGIAN 1 - MAKLUMAT PEGAWAI", :align => :left, :size => 12, :style => :bold     
    text "(Diisi oleh PYD)", :align => :left, :size => 12
    
    data1 = [['	i.', "Nama : "],
      ["ii.","Jawatan dan Gred : "],
      ["iii.", "Kementerian/Jabatan :"]]
      
          table1(data , :column_widths => [30,370], :cell_style => { :size => 10}) do
           row(0).borders = [:left, :right, :top]
           row(1).borders = [:left, :right]
           row(2).borders = [:left, :right, :buttom]
           row(0).background_color = 'FFE34D'
     end
     move_down 20
end
  
  def bahagian2
    
    text "BAHAGIAN II - KEGIATAN DAN SUMBANGAN DI LUAR TUGAS RASMI/LATIHAN", :align => :left, :size => 12, :style => :bold     
    text "(Diisi oleh PYD)", :align => :left, :size => 12
    move_down 10
    text "1. KEGIATAN DAN SUMBANGAN DI LUAR TUGAS RASMI", :align => :left, :size => 12, :style => :bold     
    move_down 5
    text "Senaraikan kegiatan dan sumbangan di luar tugas rasmi seperti sukan/pertubuhan/sumbangan kreatif di 
    peringkat Komuniti/Jabatan/Daerah/Negeri/Negara/Antarabangsa yang berfaedah kepada Organisasi/Komuniti/Negara 
    pada tahun yang dinilai.", :align => :left, :size => 12
    move_down 5
    
    def table_bahagian2
    
      table line_item_rows do
        row(0).font_style = :bold
        self.row_colors = ["FEFEFE", "FFFFFF"]
        self.header = true
        self.cell_style = { size: 9 }
        self.width = 525
        header = true
      end
    end
    
    
    def line_item_rows
      counter = counter || 0
      header = [[ 'Senarai kegiatan/aktiviti/sumbangan', 'Peringkat kegiatan/aktiviti/sumbangan
(nyatakan jawatan atau pencapaian)']]
      header +
        @assets.map do |asset|
        ["#{counter += 1}", "#{asset.assetcode}", "#{asset.purchasedate.try(:strftime, "%d/%m/%y")}", @view.currency(asset.purchaseprice.to_f)]
      end
    end  
     move_down 10
     
    text "2. Latihan", :align => :left, :size => 12, :style => :bold   
    move_down 5
    text "	i.	Senaraikan program latihan (seminar, kursus, bengkel dan lain-lain) yang dihadiri 
    dalam tahun yang dinilai.", :align => :left, :size => 12
     move_down 5
    
     def table_latihan2
    
       table line_item_rows2 do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]
         self.header = true
         self.cell_style = { size: 9 }
         self.width = 525
         header = true
       end
     end
    
    
     def line_item_rows2
       counter = counter || 0
       header = [[ 'Nama Latihan (Nyatakan sijil jika ada)', 'Tarikh/Tempoh', ' Tempat']]
       header +
         @assets.map do |asset|
         ["#{counter += 1}", "#{asset.assetcode}", "#{asset.purchasedate.try(:strftime, "%d/%m/%y")}", @view.currency(asset.purchaseprice.to_f)]
       end
     end   
     move_down 5
    text " ii. Senaraikan latihan yang diperlukan.", :align => :left, :size => 12
     move_down 5
     
     def table_latihan3
    
       table line_item_rows3 do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]
         self.header = true
         self.cell_style = { size: 9 }
         self.width = 525
         header = true
       end
     end
    
    
     def line_item_rows3
       counter = counter || 0
       header = [[ 'Nama/Bidang Latihan', 'Sebab Diperlukan']]
       header +
         @assets.map do |asset|
         ["#{counter += 1}", "#{asset.assetcode}", "#{asset.purchasedate.try(:strftime, "%d/%m/%y")}", @view.currency(asset.purchaseprice.to_f)]
       end
     end       
     move_down 5  
    text "Saya mengesahkan bahawa semua kenyataan di atas adalah benar.", :align => :left, :size => 12 
     move_down 5   
     
     data1 = [["",""],
           [ "Tandatangan PYD", "Tarikh"]] 
           
           table(data1 , :column_widths => [150,150], :cell_style => { :size => 11}) do
             row(0).font_style = :bold
             self.row_colors = ["FEFEFE", "FFFFFF"]
           end
end

def bahagian3
  
  text "BAHAGIAN III - PENGHASILAN KERJA ( Wajaran 50% )", :align => :left, :size => 12, :style => :bold     
  text "Pegawai Penilai dikehendaki memberikan penilaian berdasarkan pencapaian kerja sebenar PYD berbanding dengan SKT yang ditetapkan. 
  Penilaian hendaklah berasaskan kepada penjelasan setiap kriteria yang dinyatakan di bawah dengan menggunakan skala 1 
  hingga 10 :", :align => :left, :size => 12
  
  data1 = [["", "KRITERIA (Dinilai berasaskan SKT)", "PPP", "PPK"],
           ["1.", "   KUANTITI HASIL KERJA", "", ""],
           ["","Kuantiti hasil kerja seperti jumlah bilangan, kadar, kekerapan dan sebagainya berbanding dengan sasaran kuantiti 
             kerja yang ditetapkan.", "" , "" ],
             ["2. ","  KUALITI HASIL KERJA", "",""],
             ["2.1. Dinilai dari segi kesempurnaan, teratur dan kemas.", "",""],
             ["2.2. Dinilai dari segi usaha dan inisiatif untuk mencapai kesempurnaan hasil kerja.","",""],
             ["3. ","  KETEPATAN MASA","",""],
             ["","Kebolehan menghasilkan kerja atau melaksanakan tugas dalam tempoh masa yang ditetapkan.","",""],
             ["4. ","  KEBERKESANAN HASIL KERJA", "",""],
             ["","Dinilai dari segi memenuhi kehendak 'stake-holder' atau pelanggan.","",""],
             ["", "Jumlah markah mengikut wajaran","",""]]
             
       table(data1 , :column_widths => [100,100,100], :cell_style => { :size => 11}) do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]

       end 
end

def bahagian4
  
  text "BAHAGIAN IV - PENGETAHUAN DAN KEMAHIRAN ( Wajaran 25% )", :align => :left, :size => 12, :style => :bold     
  text "Pegawai Penilai dikehendaki memberikan penilaian berasaskan kepada penjelasan setiap kriteria yang 
  dinyatakan di bawah dengan menggunakan skala 1 hingga 10:", :align => :left, :size => 12
  
  data1 = [["", "KRITERIA ", "PPP", "PPK"],
           ["1.", "  ILMU PENGETAHUAN DAN KEMAHIRAN DALAM BIDANG KERJA", "", ""],
           ["","Mempunyai ilmu pengetahuan dan kemahiran/kepakaran dalam menghasilkan kerja meliputi kebolehan mengenalpasti, 
             menganalisis serta menyelesaikan masalah.", "" , "" ],
             ["2. ","  PELAKSANAAN DASAR, PERATURAN DAN ARAHAN PENTADBIRAN", "",""],
             ["","Kebolehan menghayati dan melaksanakan dasar, peraturan dan arahan pentadbiran berkaitan dengan bidang tugasnya.", "",""],
             ["3. ","  KUANTITI HASIL KERJA","",""],
             ["","Kuantiti hasil kerja seperti jumlah bilangan, kadar, kekerapan dan sebagainya berbanding dengan sasaran 
               kuantiti kerja yang ditetapkan.","",""],
             ["", "Jumlah markah mengikut wajaran","",""]]
             
       table(data1 , :column_widths => [100,100,100], :cell_style => { :size => 11}) do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]

       end 
end

def bahagian5
  
  text "BAHAGIAN V - KUALITI PERIBADI ( Wajaran 20% )", :align => :left, :size => 12, :style => :bold     
  text "Pegawai Penilai dikehendaki memberikan penilaian berasaskan kepada penjelasan setiap kriteria yang 
  dinyatakan di bawah dengan menggunakan skala 1 hingga 10:", :align => :left, :size => 12
  
  data1 = [["", "KRITERIA (Dinilai berasaskan SKT)", "PPP", "PPK"],
           ["1.", "  KEBOLEHAN MENGELOLA", "", ""],
           ["","Keupayaan dan kebolehan menggembleng segala sumber dalam kawalannya seperti kewangan, tenaga manusia,
             peralatan dan maklumat bagi merancang mengatur, membahagi dan mengendalikan sesuatu tugas untuk mencapai objektif 
             organisasi.", "" , "" ],
             ["2. ","   DISIPLIN", "",""],
             ["","Mempunyai daya kawalan diri dari segi mental dan fizikal termasuk mematuhi peraturan, menepati masa, 
               menunaikan janji dan bersifat sabar.", "",""],
             ["3. ","   PROAKTIF DAN INOVATIF","",""],
             ["","Kebolehan menjangka kemungkinan, mencipta dan mengeluarkan idea baru serta membuat pembaharuan bagi 
               mempertingkatkan kualiti dan produktiviti organisasi.","",""],
             ["4. ","   JALINAN HUBUNGAN DAN KERJASAMA","",""],
             [""," Kebolehan pegawai dalam mewujudkan suasana kerjasama yang harmoni dan mesra serta boleh menyesuaikan diri dalam semua keadaan.","",""],
             ["", "Jumlah markah mengikut wajaran","",""]]
             
       table(data1 , :column_widths => [100,100,100], :cell_style => { :size => 11}) do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]

       end 
end

def bahagian6
  
  text "BAHAGIAN VI - KEGIATAN DAN SUMBANGAN DI LUAR TUGAS RASMI ( Wajaran 5% )", :align => :left, :size => 12, :style => :bold  
  text "(Sukan/Pertubuhan/Sumbangan Kreatif)", :align => :left, :size => 12
  text "Berasaskan maklumat di Bahagian II perenggan 1, Pegawai Penilai dikehendaki memberi penilaian dengan menggunakan 
  skala 1 hingga 10. TIada sebarang markah boleh diberikan (kosong) jika PYD tidak mencatat kegiatan atau 
  sumbangannya.", :align => :left, :size => 12
  
  data1 = [[ "", "Peringkat Komuniti / Jabatan / Daerah / Negeri / Negara / Antarabangsa", "PPP", "PPK"],
             ["","Jumlah markah mengikut wajaran","",""]]
             
       table(data1 , :column_widths => [100,100,100], :cell_style => { :size => 11}) do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]

       end 
end

def bahagian7
  
  text "BAHAGIAN VII - JUMLAH MARKAH KESELURUHAN", :align => :left, :size => 12, :style => :bold  
  text "Pegawai Penilai dikehendaki mencatatkan jumlah markah keseluruhan yang diperolehi oleh PYD dalam bentuk peratus 
  (%) berdasarkan jumlah markah bagi setiap Bahagian yang diberi markah.", :align => :left, :size => 12

  
  data1 = [[ "", "PPP(%)", "PPK(%)", "MARKAH PURATA (%)"],
            ["", "", "", "(untuk diisi oleh Urus Setia PPSM)"]
             ["MARKAH KESELURUHAN"," ","",""]]
             
       table(data1 , :column_widths => [100,100,100], :cell_style => { :size => 11}) do
         row(0).font_style = :bold
         self.row_colors = ["FEFEFE", "FFFFFF"]

       end 
end

def bahagian8
  
  text "BAHAGIAN VIII - ULASAN KESELURUHAN DAN PENGESAHAN OLEH PEGAWAI PENILAI PERTAMA", :align => :left, :size => 12, :style => :bold  
  text "1.  Tempoh PYD bertugas di bawah pengawasan: Tahun ... Bulan ....", :align => :left, :size => 12
  text "2.  Penilai Pertama hendaklah memberi ulasan keseluruhan prestasi PYD.", :align => :left, :size => 12
  text "(i)  Prestasi keseluruhan.", :align => :left, :size => 12
  text "..............", :align => :left, :size => 12
  text "(ii)  Kemajuan kerjaya.", :align => :left, :size => 12
  text "..............", :align => :left, :size => 12
  text "3.  Adalah disahkan bahawa prestasi pegawai ini telah dimaklumkan kepada PYD.", :align => :left, :size => 12
  
  data1 = [[ "Nama PPP :", "....."],
            ["Jawatan :", "......"]
             ["Kementerian /Jabatan : ","....."]
           ["No. K.P : ","....."]]
             
       table(data1 , :column_widths => [100,200], :cell_style => { :size => 11}) do
         self.row_colors = ["FEFEFE", "FFFFFF"]
     move_down 5
       end 
       
       data1 = [["",""],
             [ "Tandatangan PPP", "Tarikh"]] 
           
             table(data1 , :column_widths => [150,150], :cell_style => { :size => 11}) do
               row(0).font_style = :bold
               self.row_colors = ["FEFEFE", "FFFFFF"]
             end
      move_down 5      
end

def bahagian9
  
  text "BAHAGIAN IX - ULASAN KESELURUHAN OLEH PEGAWAI PENILAI KEDUA", :align => :left, :size => 12, :style => :bold  
  text "1.  Tempoh PYD bertugas di bawah pengawasan: Tahun ... Bulan ....", :align => :left, :size => 12
  text "2.  Penilai Pertama hendaklah memberi ulasan keseluruhan prestasi PYD.", :align => :left, :size => 12
  text "..............", :align => :left, :size => 12
  
  data1 = [[ "Nama PPK :", "....."],
            ["Jawatan :", "......"]
             ["Kementerian /Jabatan : ","....."]
           ["No. K.P : ","....."]]
             
       table(data1 , :column_widths => [100,200], :cell_style => { :size => 11}) do
         self.row_colors = ["FEFEFE", "FFFFFF"]
     move_down 5
       end 
       
       data1 = [["",""],
             [ "Tandatangan PPP", "Tarikh"]] 
           
             table(data1 , :column_widths => [150,150], :cell_style => { :size => 11}) do
               row(0).font_style = :bold
               self.row_colors = ["FEFEFE", "FFFFFF"]
             end
      move_down 5      
end

def lampiranA
  
  text "LAMPIRAN 'A", :align => :right, :size => 12, :style => :bold 
  text "SASARAN KERJA TAHUNAN", :align => :center, :size => 12, :style => :bold 
  
  
  
  data = [["PERINGATAN"],
         ["Pegawai Yang Dinilai (PYD) dan Pegawai Penilaian Pertama (PPP) 
           hendaklah memberi perhatian kepada perkara-perkara berikut sebelum dan semasa melengkapkan borang ini:" ]]
 
  table(data , :column_widths => [400], :cell_style => { :size => 10}) do
   row(0).borders = [:left, :right, :top]
   row(1).borders = [:left, :right]
   row(0).font_style = :bold
   row(0).background_color = 'FFE34D'

  end 
  
  data1 = [['	i.', "PYD dan PPD hendaklah berbincang bersama dalam membuat penetapan Sasaran Kerja Tahunan 
    (SKT) dan menurunkan tandatangan di ruangan yang ditetapkan di Bahagian I"],
    ["ii.","SKT yang ditetapkan hendaklah mengandungi sekurang-kurangnya satu petunjuk prestasi iaitu sama ada kuantiti, kualiti,
       masa atau kos bergantung kepada kesesuaian sesuatu aktiviti/projek:"],
    ["iii.", "SKT yang telah ditetapkan pada awal tahun hendaklah dikaji semula di pertengahan tahun, 
      SKT yang digugurkan atau ditambah hendaklah dicatatkan di ruangan Bahagian II"],
      ["	iv.", "PYD dan PPP hendaklah membuat laporan dan ulasan keseluruhan pencapaian SKT pada akhir 
        tahun serta menurunkan tandatangan di ruangan yang ditetapkan di Bahagian III; dan"],
      ["v.", "sila rujuk Panduan Penyediaan Sasaran Kerja Tahunan (SKT) untuk mendapat keterangan lanjut."]]
    
        table1(data , :column_widths => [30,370], :cell_style => { :size => 10}) do
         row(0).borders = [:left, :right]
         row(1).borders = [:left, :right]
         row(2).borders = [:left, :right]
         row(3).borders = [:left, :right]
         row(4).borders = [:left, :right, :buttom]
         row(0).background_color = 'FFE34D'
    end
    move_down 20 
end

def lampiranA1
  
  text "BAHAGIAN I -  MAKLUMAT PEGAWAI", :align => :left, :size => 12, :style => :bold  
  text "(PYD dan PPP hendaklah berbincang bersama sebelum menetapkan SKT dan petunjuk prestasinya)", :align => :left, :size => 12  
  
  
  data = [["Bil", "Ringkasan Aktiviti/Projek", "Petunjuk Prestasi"]]
  
  data1 = [["",""],
        [ "Tandatangan PYD", "Tandatangan PPP"],
        ["Tarikh :", "Tarikh : "]] 
      
        table(data1 , :column_widths => [150,150], :cell_style => { :size => 11}) do
          row(0).font_style = :bold
          self.row_colors = ["FEFEFE", "FFFFFF"]
        end 
  
end

def lampiranA2
  
  text "BAHAGIAN II -  Kajian Semula Sasaran Kerja Tahun Pertengahan Tahun", :align => :left, :size => 12, :style => :bold  
  text "1.   Aktiviti/Projek Yang Ditambah", :align => :left, :size => 12  
  text "(PYD hendaklah menyeneraikan aktiviti/projek yang ditambah berserta petunjuk prestasinya setelah berbincang dengan PPP)", :align => :left, :size => 12  
  
  
  data = [["Bil", "Ringkasan Aktiviti/Projek", "Petunjuk Prestasi"]]
  
  text "BAHAGIAN II - Kajian Semula Sasaran Kerja Tahun Pertengahan Tahun", :align => :left, :size => 12, :style => :bold 
  text "1.   Aktiviti/Projek Yang Digugurkan", :align => :left, :size => 12, :style => :bold 
  text "(PYD hendaklah menyeneraikan aktiviti/projek yang digugurkan setelah berbincang dengan PPP)", :align => :left, :size => 12, :style => :bold 
  
  data = [["Bil", "Ringkasan Aktiviti/Projek"]]
  
    
end

def lampiranA3
  
  text "BAHAGIAN III -  Laporan dan Ulasan Keseluruhan Pencapaian Sasaran Kerja Tahunan Pada Akhir 
                        Tahun Oleh PYD dan PPP", :align => :left, :size => 12, :style => :bold  
                        
  text "1.   Laporan/Ulasan Oleh PYD", :align => :left, :size => 12  

    data = [["  "]]
  
  text "2.   Laporan/Ulasan Oleh PPP", :align => :left, :size => 12, :style => :bold 
  
  data1 = [["  "]]
  
  
  
  data2 = [["",""],
        [ "Tandatangan PYD", "Tandatangan PPP"],
        ["Tarikh :", "Tarikh : "]] 
      
        table(data2 , :column_widths => [150,150], :cell_style => { :size => 11}) do
          row(0).font_style = :bold
          self.row_colors = ["FEFEFE", "FFFFFF"]
        end 
  
    
end

end