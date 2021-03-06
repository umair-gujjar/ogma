require 'spec_helper'

describe "Staff Appraisal pages" do
  
  before { @employgrade = FactoryGirl.create(:employgrade)}
  before { @appraised = FactoryGirl.create(:staff, :staffgrade => @employgrade)}
  before { @staff_appraisal = FactoryGirl.create(:staff_appraisal, :appraised => @appraised) }
  
  subject { page }

  describe "Staff Appraisal Index page" do 
    before { visit staff_staff_appraisals_path }
      it { should have_selector('h1', text: I18n.t('staff.staff_appraisal.title')) }
      it { should have_link("New",    href: new_staff_staff_appraisal_path + "?locale=en")}
      it { should have_selector(:link_or_button, I18n.t('actions.search'))}    
      it { should have_selector(:link_or_button, I18n.t('actions.print'))}
      it { should have_selector('th', text: I18n.t('staff.icno')) }
      it { should have_selector('th', text: I18n.t('staff.name')) }
      it { should have_selector('th', text: I18n.t('staff.position'))}
      it { should have_selector('th', text: I18n.t('helpers.label.staff_appraisal.evaluation_year'))}
      it { should have_selector('th', text: "Status")}
      it { should have_link(formatted_mykad(@staff_appraisal.appraised.icno), href: staff_staff_appraisal_path(@staff_appraisal) + "?locale=en") }
    end
   
    
  describe "Staff Appraisal Show Page" do
    before { visit staff_staff_appraisal_path(@staff_appraisal)}   
    it {should have_selector('h1', text: I18n.t('staff.staff_appraisal.title'))}
    it { should have_selector(:link_or_button, I18n.t( 'staff.staff_appraisal.skt'))}    
    it { should have_selector(:link_or_button, I18n.t('staff.staff_appraisal.activity'))}
    it { should have_selector(:link_or_button, I18n.t('staff.staff_appraisal.evaluation_performance'))}
    it { should have_selector(:link_or_button, I18n.t('staff.staff_appraisal.review'))}
    
    it { should have_selector(:link_or_button, I18n.t('back'))}    
    it { should have_selector(:link_or_button, I18n.t('actions.edit'))}    
    it { should have_selector(:link_or_button, I18n.t('helpers.links.destroy'))}    
  end
  
  describe "Staff Appraisal New page" do
    before { visit new_staff_staff_appraisal_path }
    it { should have_selector('h1', text: I18n.t('staff.staff_appraisal.new')) }
    it { should have_selector(:link_or_button, I18n.t('.back'))}    
    it { should have_selector(:link_or_button, I18n.t('create'))}    
  end
    
  describe "Staff Appraisal Edit page" do
    before { visit edit_staff_staff_appraisal_path(@staff_appraisal)}
    it { should have_selector('h1', text: I18n.t('staff.staff_appraisal.edit')) }
    it { should have_selector(:link_or_button, I18n.t('.back'))}  
    it { should have_selector(:link_or_button, I18n.t('update'))}
  end
    
end 