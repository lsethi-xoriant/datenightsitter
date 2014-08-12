require 'rails_helper'

RSpec.describe SittercityAccount do
  
  context "with an authenticated provider" do
    let(:creds) { FactoryGirl.attributes_for(:creds) }
    subject {
      s = Sittercity::API::Client.new( Rails.application.secrets.sittercity_api_endpoint )
      s.register(:application_type => Rails.application.secrets.sittercity_api_application_type ,
                 :name => Rails.application.secrets.sittercity_api_application_name )
      s.authenticate!(:email => creds[:email], :password => creds[:password])
      SittercityAccount.new(s)
    }
    
    it "#sso_uuid returns a GUID" do
      expect(subject.sso_uuid).to be_a(String)
    end
    
    it "#first_name returns a string" do
      expect(subject.first_name).to be_a(String)
    end
    
    it "#last_name returns a string" do
      expect(subject.last_name).to be_a(String)
    end
    
    it "#location returns a location hash" do
      expect(subject.location).to be_a(Hash)
    end

    it "#is_member? is false" do
      expect(subject.is_member?).to be_falsey
    end
    
    it "#is_provider? is true" do
      expect(subject.is_provider?).to be_truthy
    end
    
    it "#is_seeker? is false" do
      expect(subject.is_seeker?).to be_falsey
    end
    
    it "#has_expired? is false" do
      expect(subject.has_expired?).to be_falsey
    end
    
    it "#authentication_expires_at returns a String that can be parsed by Time" do
      expect(subject.authentication_expires_at).to be_a(Time)
    end
    
    it "#refresh_authentication returns a Sittercity::API::Client::Token" do
      expect(subject.refresh_authentication).to be_a(Sittercity::API::Client::Token)
    end
    
    it "#provider_profile returns a SittercityProfile object" do
      expect(subject.provider_profile).to be_a(SittercityProfile)
    end
    
  end

end
