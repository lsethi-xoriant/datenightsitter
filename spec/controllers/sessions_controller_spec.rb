require 'rails_helper'

RSpec.describe SessionsController, :type => :controller do

  describe "GET #new" do
    context "with a user who hasn't saved their password" do
      subject{ get :new }
      it "responds with an HTTP SUCCESS" do
        expect(subject).to be_success
      end
      
      it "displays a new user login-up page" do
        expect(subject).to render_template("sessions/new")
        expect(subject).to render_template(:new)
      end
    end
    
    context "with a provider who saved their password" do
      let(:mem) { FactoryGirl.create( :provider )}
      
      before(:each) do
        cookies.encrypted[:member_id] = { value: mem.id, expires: 1.month.from_now }        
      end
      
      subject{ get :new }
      it "responds with an HTTP REDIRECT" do
        expect(subject).to be_redirect
      end
      
      it "redirects to the dashboard" do
        expect(subject).to redirect_to(dashboard_member_path(mem))
      end
      
    end
    
  end

  describe "GET #destroy" do
    let(:mem) { FactoryGirl.create( :provider )}
    
    context "if the user did not save their password" do
      
      before(:each) do
        session[:member_id] = mem.id
        get :destroy
      end
      
      it "responds with an HTTP REDIRECT" do
        expect(response).to be_redirect
      end
      
      it "deletes an authentication cookie" do
        expect(session[:member_id]).to be_falsey
      end
      
      it "redirects to the log_in page" do
        expect(response).to redirect_to(log_in_path)
      end
    end
    

    context "if the user has saved their password" do
      before(:each) do
        cookies.encrypted[:member_id] = mem.id
        get :destroy, nil, {:member_id => mem.id}
      end
      
      it "deletes a saved password cookie" do
        expect(cookies.encrypted[:member_id]).to be_falsey
      end
    end
  end
  
  describe "GET #forgot_password" do
    subject{ get :forgot_password }
    it "responds with an HTTP SUCCESS" do
      expect(subject).to be_success
    end
    
    it "displays the forgot password page" do
      expect(subject).to render_template(:forgot_password)
    end
  end
    
  describe "POST #create (log in)" do
    let(:mem) { FactoryGirl.create( :provider, :password => "captainhappypants" )}
    
    context "provider provides correct credentials" do

      before(:each) do
        post :create, {:email => mem.email, :password => "captainhappypants" }
      end
  
      it "responds with an HTTP REDIRECT" do
        expect(response).to be_redirect
      end
      
      it "redirects to the provider dashboard" do
        expect(response).to redirect_to(dashboard_member_path(mem))
      end
    end
    
    context "provider provides incorrect credentials" do

      before(:each) do
        post :create, {:email => mem.email, :password => "something else" }
      end
  
      it "responds with an HTTP SUCCESS" do
        expect(response).to be_success
      end
      
      it "displays log in page" do
        expect(response).to render_template(:new)
      end
    end
    
  end
  
  describe "POST #verify_member" do
    
    context "member provides correct phone" do
      let(:mem) { FactoryGirl.create( :provider, :phone => "3129700557" )}
      
      before(:each) do
        post :verify_member, {:email => "", :phone => mem.phone }
      end
  
      it "responds with an HTTP SUCCESS" do
        expect(response).to be_success
      end
      
      it "displays the verification page" do
        expect(response).to render_template(:verify_member)
      end
    end
    
    context "member provides incorrect phone" do
      let(:mem) { FactoryGirl.create( :provider, :phone => "3129700557" )}
      
      before(:each) do
        post :verify_member, {:email => "", :phone => "3125551212" }
      end
      
      it "responds with an HTTP REDIRECT" do
        expect(response).to be_redirect
      end
      
      it "redirects to the forgot password page" do
        expect(response).to redirect_to(forgot_password_sessions_path)
      end
    end
    
  end
 
   describe "POST #change_password" do
    
    context "member provides correct token" do
      let(:mem) { FactoryGirl.create( :provider, :phone => "3129700557" )}
      let(:pass) { SecureRandom.random_number(900000)+ 100000 }
      let(:pw) { Faker::Internet.password(8) }
      
      before(:each) do
        session[:verification_token] = BCrypt::Password.create(pass)
        post :change_password, {:member_id => mem.id, :code => pass, :pasword => pw }
      end
  
      it "responds with an HTTP REDIRECT" do
        expect(response).to be_redirect
      end
      
      it "displays the verification page" do
        expect(response).to redirect_to(dashboard_member_path(mem))
      end
    end

    context "member provides incorrect token" do
      let(:mem) { FactoryGirl.create( :provider, :phone => "3129700557" )}
      let(:pass) { SecureRandom.random_number(900000)+ 100000 }
      let(:fail) { SecureRandom.random_number(900000)+ 100000 }
      let(:pw) { Faker::Internet.password(8) }
      
      before(:each) do
        session[:verification_token] = BCrypt::Password.create(pass)
        post :change_password, {:member_id => mem.id, :code => fail, :pasword => pw }
      end
  
      it "responds with an HTTP REDIRECT" do
        expect(response).to be_redirect
      end
      
      it "displays the verification page" do
        expect(response).to redirect_to(forgot_password_sessions_path)
      end
    end
  end

end
