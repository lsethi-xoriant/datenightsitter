require 'rails_helper'

RSpec.describe MembersController, :type => :controller do
  
  describe "GET #new" do
    subject{ get :new }
    it "responds with an HTTP SUCCESS" do
      expect(subject).to be_success
    end
    
    it "displays a new user sign-up page" do
      expect(subject).to render_template("members/new")
      expect(subject).to render_template(:new)
    end
    
  end
  
  describe "POST #create" do
    context "with valid seeker attributes" do
      let (:seeker) { FactoryGirl.attributes_for(:seeker) }
      
      before(:each) do
        post :create, member: seeker
        @last_seeker = Seeker.last
      end
      
      it "redirects to the dashboard" do
        expect(response).to redirect_to(dashboard_member_path(@last_seeker))
      end
      
       it "creates a seeker matching the attributes posted" do
        @last_seeker = Seeker.last
        expect(@last_seeker).to be_a(Seeker)
        expect(@last_seeker.first_name).to eq(seeker[:first_name])
        expect(@last_seeker.address).to eq(seeker[:address])
      end
    end
    
    context "with valid provider attributes" do
      let (:provider) { FactoryGirl.attributes_for(:provider) }
      
      before(:each) do
        post :create, member: provider
        @last_provider = Provider.last
      end
      
      it "redirects to the dashboard" do
        expect(response).to redirect_to(dashboard_member_path(@last_provider))
      end
      
       it "creates a provider matching the attributes posted" do
        expect(@last_provider).to be_a(Provider)
        expect(@last_provider.first_name).to eq(provider[:first_name])
        expect(@last_provider.address).to eq(provider[:address])
        expect(@last_provider.date_of_birth).to eq(provider[:date_of_birth])
      end
    end
  end
  
  describe "GET #dashboard" do
    context "when a provider is logged in" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        session[:member_id] = provider.id
        get :dashboard, :id => provider
      end
      
      it "displays the providers dashbboard" do
        expect(response).to render_template(:provider_dashboard)
      end
    end
    
    context "when a seeker is logged in" do
      let(:seeker) {FactoryGirl.create(:seeker)}
      
      it "displays dashboard for seekers(parents)" do
        session[:member_id] = seeker.id
        get :dashboard, :id => seeker
        expect(response).to render_template(:seeker_dashboard)
      end
      
      it "responds with an HTTP SUCCESS" do
        expect(response).to be_success
      end
    end
  end
  
  describe "GET #bank_account" do
    context "when a provider is logged in" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        session[:member_id] = provider.id
        get :bank_account, :id => provider
      end
      
      it "displays a page to add bank account for a provider" do
        expect(response).to render_template(:bank_account)
      end
      
      it "responds with an HTTP SUCCESS" do
        expect(response).to be_success
      end
    end
    
    context "when a seeker is logged in" do
      let(:seeker) {FactoryGirl.create(:seeker)}
      
      before(:each) do
        session[:member_id] = seeker.id
        get :bank_account, :id => seeker
      end
      
      it "redirects to the dashboard" do
        expect(response).to redirect_to(dashboard_member_path(seeker))
      end
      
      it "is redirected" do
        expect(response).to have_http_status(:redirect)
      end
    end
    
    context "when no valid user is logged in" do
      before(:each) do
        get :bank_account, :id => 1
      end
      
      it "redirects to the homepage" do
        expect(response).to redirect_to(:log_in)
      end
      
      it "is redirected" do
        expect(response).to have_http_status(:redirect)
      end
    end
      
    
  end
  
  describe "POST #add_bank_account" do
    context "when a provider supplies valid merchant account information" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        session[:member_id] = provider.id
        post :add_bank_account, :id => provider, :routing_number => "071101307", :account_number => "80735962893222", :tos => true
      end
      
      it "redirects to the dashboard" do
        expect(response).to redirect_to(dashboard_member_path(provider))
      end
      
      it "has a merchant account" do
        provider.reload
        expect(provider.has_merchant_account?).to be_truthy
      end
      
    end
    
    context "when a provider does not supply merchant account information" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        session[:member_id] = provider.id
        post :add_bank_account, :id => provider
      end

      it "does not update" do
        provider.reload
        expect(provider.has_merchant_account?).to be_falsey
      end

      it "displays the bank account information page" do
        expect(response).to render_template(:bank_account)
      end
      
      it "displays an error message" do
        expect(flash[:danger]).to be_truthy
      end
      
    end
  end
  
  describe "GET #settle_up" do
    context "when a provider is logged in" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        session[:member_id] = provider.id
        get :settle_up, :id => provider
      end
      
      it "displays a page to request money for a completed babysitting job/event" do
        expect(response).to render_template(:settle_up)
      end
    end
  end
  
  describe "POST #submit_bill" do
    context "when a provider is logged in and the seeker exists" do
      let(:provider) {FactoryGirl.create(:provider)}
      let(:seeker) {FactoryGirl.create(:seeker_for_comm)}
      let(:trans) { FactoryGirl.attributes_for(:trans_initiate) }
      
      before(:each) do
        session[:member_id] = provider.id
        post :submit_bill, :id => provider,
                            :seeker_phone => seeker.phone,
                            :seeker_last_name => seeker.last_name,
                            :started_at => trans[:started_at],
                            :duration_hours => trans[:duration],
                            :rate => trans[:rate]
        @seeker = Seeker.find_by(:phone => seeker.phone)
      end
      
      it "creates a transaction with the existing seeker" do
        last_trans = provider.transactions.last
        expect(last_trans).to be_valid
        expect(last_trans.duration).to eq(trans[:duration])
        expect(last_trans.rate).to eq(trans[:rate])
      end
    end
    
    context "when a provider is logged in and the seeker does not exist" do
      let(:provider) { FactoryGirl.create(:provider) }
      let(:trans) { FactoryGirl.attributes_for(:trans_initiate) }
      
      before(:each) do
        session[:member_id] = provider.id
        post :submit_bill, :id => provider,
                            :seeker_phone => "3129700557",
                            :seeker_last_name => Faker::Name.last_name,
                            :started_at => trans[:started_at],
                            :duration_hours => trans[:duration],
                            :rate => trans[:rate]
        @seeker = Seeker.find_by(:phone => "3129700557")
      end
      
      it "creates a seeker record" do
        expect(@seeker.phone).to eq("3129700557")
      end
      
      it "creates a transaction with the new seeker" do
        last_trans = @seeker.transactions.last
        expect(last_trans).to be_valid
        expect(last_trans.duration).to eq(trans[:duration])
        expect(last_trans.rate).to eq(trans[:rate])
        
      end
      
    end
  end
  

end
