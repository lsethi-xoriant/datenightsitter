require 'rails_helper'

RSpec.describe MembersController, :type => :controller do
  RSpec.shared_examples 'a protected page' do |method, template|
    subject { get method, :id => member }
    
    before(:each) do
      sign_in member
    end
    
    it "responds with an HTTP SUCCESS" do
      expect(subject).to be_success
    end
    
    it "displays the template: #{template}" do
      expect(subject).to render_template(template)
    end     
  end

  RSpec.shared_examples 'an unprotected page' do |method, template|
    subject { get method, :id => member }
    
    it "responds with an HTTP SUCCESS" do
      expect(subject).to be_success
    end
    
    it "displays the template: #{template}" do
      expect(subject).to render_template(template)
    end     
  end
  

  describe "GET #dashboard" do
    method = "dashboard"
    
    context "as a provider" do
      it_behaves_like "a protected page", method, "provider_#{method}" do
        let(:member) {FactoryGirl.create(:provider)}
      end
    end
    
    context "as a seeker" do
      it_behaves_like "a protected page", method, "seeker_#{method}" do
        let(:member) {FactoryGirl.create(:seeker)}
      end
    end
  end

  describe "GET #profile" do
    method = "profile"
    
    context "as a provider" do
      it_behaves_like "a protected page", method, method do 
        let(:member) {FactoryGirl.create(:provider)}
      end
    end
    
    context "as a seeker" do
      it_behaves_like "a protected page", method, method do
        let(:member) {FactoryGirl.create(:seeker)}
      end
    end
  end
  
  describe "GET #terms_of_use" do
    method = "terms_of_use"
    
    context "as a provider" do
      it_behaves_like "a protected page", method, method do 
        let(:member) {FactoryGirl.create(:provider)}
      end
    end
    
    context "as a seeker" do
      it_behaves_like "a protected page", method, method do
        let(:member) {FactoryGirl.create(:seeker)}
      end
    end
  end
  
  describe "GET #invite_parent" do
    method = "invite_parent"
    
    context "as a provider" do
      it_behaves_like "a protected page", method, method do 
        let(:member) {FactoryGirl.create(:provider)}
      end
    end
  end
  
  describe "GET #invited" do
    method = "invited"
    
    context "as a seeker" do
      it_behaves_like "an unprotected page", method, method do
        let(:member) {FactoryGirl.create(:seeker)}
      end
    end
  end
  
  describe "POST #update" do
    
  end
  
  describe "#POST add_seeker" do
    let(:provider) {FactoryGirl.create(:provider)}
    
    context "with valid seeker parameters" do
      let(:seeker) { FactoryGirl.attributes_for(:seeker_for_comm)}
      subject { post :add_seeker, :id => provider, :seeker => seeker }
      
      before(:each) do
        sign_in provider
      end
      
      it "redirects to the dashboard" do
        expect(subject).to redirect_to(dashboard_member_path(provider))
      end
      
      it "adds a new seeker" do
        expect(subject).to be_redirect
        expect(Seeker.last.email).to eq(seeker[:email])
      end
    end
    
    context "with invalid seeker parameters" do
      let(:seeker) { FactoryGirl.attributes_for(:seeker_for_comm, :email => "alpha")}
      subject { post :add_seeker, :id => provider, :seeker => seeker }
      
      before(:each) do
        sign_in provider
      end
      
      it "shows #invite_parent" do
        expect(subject.code).to eq("200")
      end

      it "shows #invite_parent" do
        expect(subject).to render_template("invite_parent")
      end
    end
    
  end
  
  describe "GET #bank_account" do
    context "as a provider" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        sign_in provider
        get :bank_account, :id => provider
      end
      
      it "displays a page to add bank account for a provider" do
        expect(response).to render_template(:bank_account)
      end
      
      it "responds with an HTTP SUCCESS" do
        expect(response).to be_success
      end
    end
    
    context "as a seeker" do
      let(:seeker) {FactoryGirl.create(:seeker)}
      
      before(:each) do
        sign_in seeker
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
        sign_in provider
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
        sign_in provider
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
    context "as a provider" do
      let(:provider) {FactoryGirl.create(:provider)}
      
      before(:each) do
        sign_in provider
        get :settle_up, :id => provider
      end
      
      it "displays a page to request money for a completed babysitting job/event" do
        expect(response).to render_template(:settle_up)
      end
    end
  end
  
  describe "POST #submit_bill" do
    context "as a provider and the seeker exists but not in the providers network" do
      let(:provider) {FactoryGirl.create(:provider)}
      let(:seeker) {FactoryGirl.create(:seeker_for_comm)}
      let(:trans) { FactoryGirl.attributes_for(:trans_request_params) }
      
      before(:each) do
        sign_in provider
        post :submit_bill, :id => provider,
                            :seeker => {:phone => seeker.phone, :last_name => seeker.last_name},
                            :transaction => trans
        @seeker = Seeker.find_by(:phone => seeker.phone)
      end
      
      it "creates a transaction with the existing seeker" do
        last_trans = provider.transactions.last
        expect(last_trans).to be_valid
        expect(last_trans.duration).to eq(trans[:duration])
        expect(last_trans.rate).to eq(trans[:rate])
      end
    end
    
    context "as a provider and the seeker exists and in the providers network" do
      let(:provider) {FactoryGirl.create(:provider)}
      let(:seeker) {FactoryGirl.create(:seeker_for_comm)}
      let(:trans) { FactoryGirl.attributes_for(:trans_request_params) }
      
      before(:each) do
        sign_in provider
        post :submit_bill, :id => provider,
                            :seeker => {:id => seeker.id },
                            :transaction => trans
        @seeker = Seeker.find_by(:id => seeker.id)
      end
      
      it "creates a transaction with the existing seeker" do
        last_trans = provider.transactions.last
        expect(last_trans).to be_valid
        expect(last_trans.duration).to eq(trans[:duration])
        expect(last_trans.rate).to eq(trans[:rate])
      end
    end
    
    context "as a provider and the seeker does not exist" do
      let(:provider) { FactoryGirl.create(:provider) }
      let(:trans) { FactoryGirl.attributes_for(:trans_request_params) }
      
      before(:each) do
        sign_in provider
        post :submit_bill, :id => provider,
                            :seeker => {:phone => "3129700557", :last_name => Faker::Name.last_name},
                            :transaction => trans
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
