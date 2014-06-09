require 'spec_helper'

describe "asset pages" do
  before  { @asset = FactoryGirl.create(:fixed_asset) }
  before  { @inventory = FactoryGirl.create(:inventory) }
  subject { page }
  

  describe "Asset Index page" do
    before { visit asset_assets_path }
    
    it { should have_selector('h1', text: 'Assets') }
    it { should have_link("", href: kewpa4_asset_assets_path(:format => 'pdf') + "?locale=en")}
    it { should have_link("", href: kewpa5_asset_assets_path(:format => 'pdf') + "?locale=en")}
    it { should have_link("", href: kewpa13_asset_assets_path(:format => 'pdf') + "?locale=en")}
    it { should have_selector('th', text: 'Registration Serial No') }
    it { should have_selector('th', text: 'Manufacturer/Brand') }
    it { should have_selector('th', text: 'Local Order Date (LO Date)')}
    it { should have_selector('th', text: 'Purchase Price')}
    it { should have_link("Fixed Assets", href: '#home')}
    it { should have_link("Inventory", href: '#profile')}
    #it { should have_link(@asset.assetcode, href: asset_asset_path(@asset) + "?locale=en" ); save_and_open_page }
  end
  
  describe "Fixed Asset Show Page" do
    before { visit asset_asset_path(@asset) }
    it { should have_selector('h1', text: @asset.assetcode) }
    it { should have_link("Details",  href: '#details')}
    it { should have_link("Description", href: '#description')}
    it { should have_link("Purchase", href: '#purchase')}
    it { should have_link("Place",    href: '#placement')}
    
    it { should have_link("", href: asset_assets_path + "?locale=en")}
    it { should have_link("", href: kewpa2_asset_asset_path(@asset, format: "pdf") + "?locale=en")}
    it { should_not have_link("", href: kewpa3_asset_asset_path(@asset, format: "pdf") + "?locale=en")}
    it { should have_link("", href: kewpa6_asset_asset_path(@asset, format: "pdf") + "?locale=en")}
    it { should have_link("", href: new_asset_defect_path(:asset_id => @asset) + "&locale=en")}
    it { should have_link("", href: edit_asset_asset_path(@asset) + "?locale=en")}
    it { should have_link("", href: asset_asset_path(@asset)+ "?locale=en")}
  end
  
  describe "Inventory Show Page" do
    before { visit asset_asset_path(@inventory) }
    it { should have_selector('h1', text: @inventory.assetcode) }
    it { should have_link("Details",  href: '#details')}
    it { should have_link("Description", href: '#description')}
    it { should have_link("Purchase", href: '#purchase')}
    it { should have_link("Place",    href: '#placement')}
    it { should_not have_link("Maintenance",    href: '#maintenance')}
    
    it { should have_link("", href: asset_assets_path + "?locale=en")}
    it { should_not have_link("", href: kewpa2_asset_asset_path(@inventory, format: "pdf") + "?locale=en")}
    it { should have_link("", href: kewpa3_asset_asset_path(@inventory, format: "pdf") + "?locale=en")}
    it { should have_link("", href: kewpa6_asset_asset_path(@inventory, format: "pdf") + "?locale=en")}
    it { should_not have_link("", href: new_asset_defect_path(:asset_id => @inventory) + "&locale=en")}
    it { should have_link("", href: edit_asset_asset_path(@inventory) + "?locale=en")}
    it { should have_link("", href: asset_asset_path(@inventory)+ "?locale=en")}
  end
  
  describe "Asset Edit Page" do
  end
  
  describe "Inventory Edit Page" do
  end
  
  describe "Report Defect Page" do
    before { visit new_asset_defect_path(:asset_id => @asset) }
    it { should have_selector('h1', text: "New Defect Report") }
    it { should have_field("asset_defect[asset_show]", :disabled => true) }
    it { should have_field("asset_defect[description]") }
    it { should have_link("Back", href: asset_assets_path + "?locale=en")}
    it { should have_selector(:link_or_button, "Create")}    
  end
  
  #have_field(id, :type => 'textarea', :disabled => true)
  #(:link_or_button, arg1)
 
end

			