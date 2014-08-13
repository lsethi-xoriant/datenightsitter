require 'rails_helper'

RSpec.describe Admin::DateNightSlotsController, :type => :controller do
  let(:admin) {FactoryGirl.create(:admin)}
  let(:dns) {FactoryGirl.create(:date_night_slot)}
  let(:dns_attribs) {FactoryGirl.attributes_for(:date_night_slot)}

  before(:each) do
    sign_in admin
  end
    
  describe "GET new" do
    subject { get :new }

    it "returns http success" do
      expect(subject).to be_success
    end
  end

  describe "POST create" do
    
    subject { post :create, :date_night_slot => dns_attribs }
    
    it "redirects to the admin/date_night_slot/index page" do
      expect(subject).to redirect_to(admin_date_night_slots_path)
    end
    
    it "creates a DateNightSlot" do
      expect(subject).to be_redirect
      expect(DateNightSlot.last.available_on.to_s).to eq(dns_attribs[:available_on].to_s)
    end
  end

  describe "PUT update" do
    
    subject { put :update, :id => dns.id, :date_night_slot => dns_attribs }

    it "redirects to the admin/date_night_slot/index page" do
      expect(subject).to redirect_to(admin_date_night_slots_path)
    end

    it "updates a DateNightSlot to not match the old values" do
      expect(subject).to be_redirect
      expect(DateNightSlot.find(dns.id).available_on.to_s).not_to eq(dns.available_on.to_s)
    end

    it "updates a DateNightSlot to match the new values" do
      expect(subject).to be_redirect
      expect(DateNightSlot.find(dns.id).available_on.to_s).to eq(dns_attribs[:available_on].to_s)
    end
  end

  describe "GET edit" do
    subject { get :edit, :id => dns.id}

    it "returns http success" do
      expect(subject).to be_success
    end
    
    it "renders edit template" do
      expect(subject).to render_template(:edit)
    end
      
  end

  describe "GET destroy" do
    subject { delete :destroy, :id => dns.id }
    
    it "redirects to the admin/date_night_slot/index page" do
      expect(subject).to redirect_to(admin_date_night_slots_path)
    end
    
    it "deletes the requested DateNightSlot" do
      expect(subject).to be_redirect
      expect(DateNightSlot.find_by_id(dns.id)).to be_nil
    end
  end

  describe "GET index" do
    
    context "with no parameters" do
      subject { get :index }
      
      it "returns http success" do
        expect(subject).to be_success
      end    
      
    end

    context "with available_on query parameter set" do
      subject { get :index, :available_on => Date.today.strftime('%Y-%m-%d') }
      
      it "returns http success" do
        expect(subject).to be_success
      end    
      
    end
  end

end
