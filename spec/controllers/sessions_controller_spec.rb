require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do

  describe "GET #new" do
    subject{ get :new }
    it "responds with an HTTP SUCCESS" do
      expect(subject).to be_success
    end
    
    it "displays a new user login-up page" do
      expect(subject).to render_template("sessions/new")
      expect(subject).to render_template(:new)
    end

    context "with a user who hasn't saved their password" do
    end
    
  end

  describe "GET #destroy" do
    let(:mem) { FactoryGirl.create( :provider )}
    
    before(:each) do
      sign_in mem
      session[:sittercity_account] = mem.id
      get :destroy
    end

    it "responds with an HTTP REDIRECT" do
      expect(response).to be_redirect
    end

    it "redirects to the log_in page" do
      expect(response).to redirect_to(log_in_path)
    end
    
  end
   
  describe "POST #create (log in)" do
    let(:creds) { FactoryGirl.attributes_for(:creds) }
    let(:mem) { FactoryGirl.create( :provider, :email => creds[:email], :password => creds[:password] )}
    
    context "provider provides correct credentials" do
      subject {post :create, :email => mem.email, :password => creds[:password] }  #use mem to force lazy execution of :let

      it "responds with an HTTP REDIRECT" do
        expect(subject).to be_redirect
      end
      
      it "redirects to the provider dashboard" do
        expect(subject).to redirect_to(dashboard_member_path(mem))
      end
    end
    
    context "provider provides incorrect credentials" do

      before(:each) do
        post :create, {:email => creds[:email], :password => "something else" }
      end
  
      it "responds with an HTTP SUCCESS" do
        expect(response).to be_success
      end
      
      it "displays log in page" do
        expect(response).to render_template(:new)
      end
    end
    
  end
  

end
