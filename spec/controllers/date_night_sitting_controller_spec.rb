require 'rails_helper'

RSpec.describe DateNightSittingController, :type => :controller do

  describe "POST create" do
      let(:provider) { FactoryGirl.create(:provider)}
      let(:dns) { FactoryGirl.attributes_for(:date_night_sitting_available, :provider_id => provider.id) }
      subject { post :create, :date_night_sitting => dns, :format => :json }
      
      before(:each) do
        sign_in provider
      end

    it "returns http success" do
      expect(subject).to be_success
    end
    
    it "returns JSON object" do
      expect(JSON.parse(subject.body)["id"]).to be > 0
    end
  end

  describe "PATCH update" do
    
    context "changing status from available to unavailable" do
      let(:provider) { FactoryGirl.create(:provider)}
      let(:dns) { FactoryGirl.create(:date_night_sitting_available, :provider_id => provider.id) }
      subject { patch :update, :id => dns.id, :date_night_sitting => {:status => "unavailable"}, :format => :json }
      
      before(:each) do
        sign_in provider
      end
      
      it "returns http success" do
        expect(subject).to be_success
      end
      
      it "returns JSON object" do
        expect(JSON.parse(subject.body)["id"]).to be > 0
      end
    
    end
  end

end
