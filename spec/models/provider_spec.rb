require 'rails_helper'

RSpec.describe Provider, :type => :model do

  context "after being created" do
    let(:provider) { FactoryGirl.create(:provider) }
    
    it "is a Provider object" do
      expect(provider).to be_valid
      expect(provider).to be_a(Provider)
    end
    
    context "and when attempting to find or create a seeker in it's network," do
      let(:seeker_attr) { FactoryGirl.attributes_for(:seeker_base_attr) }
      
      before(:each) do
      end
      
      it "creates a new Seeker if it doesn't exist" do
        seeker = Seeker.find_by_phone(seeker_attr["phone"])
        expect(seeker).to be_falsey
        seeker = provider.find_or_create_in_network(seeker_attr)
        expect(seeker).to be_valid
        expect(seeker).to be_a(Seeker)
      end
      
      it "adds the Seeker to it's network if it doesn't exist" do
        seeker = provider.find_or_create_in_network(seeker_attr)
        provider.reload
        seeker_matches = provider.network.where(:id => seeker.id)
        expect(seeker_matches).to be_truthy
        expect(seeker_matches.count).to eq(1)
      end
      
      it "does not add the Seeker to it's network if its already there" do
        seeker = provider.find_or_create_in_network(seeker_attr.with_indifferent_access)
        seeker = provider.find_or_create_in_network(seeker_attr.with_indifferent_access)
        seeker_matches = provider.network.where(:id => seeker.id)
        expect(seeker_matches).to be_truthy
        expect(seeker_matches.count).to eq(1)
      end
    end
    
    
    it "it fails to create a merchant account gracefully" do
      pfail = FactoryGirl.create(:provider_fail)
      expect(pfail.merchant_account_id).to be_nil
      pfail.create_merchant_account("11431678612343", "071101307", true)
      expect(pfail.merchant_account).to be_nil
    end
  end
  
  context "after creating a merchant account" do
    let(:trans_params) { FactoryGirl.attributes_for(:trans_request_params) }
    before(:all) do
      @provider = FactoryGirl.create(:provider)
      @provider.create_merchant_account("114313413412343", "071101307", true)
    end
    
    it "has a valid merchant account" do
      expect(@provider.merchant_account_id).to be_truthy
      expect(@provider.merchant_account).to be_truthy
    end
    
    it "can request a payment now" do
      seeker = FactoryGirl.create(:seeker, :phone => '+13129700557')   #this phone definitely works with twitter
      t = @provider.request_payment(seeker, trans_params)
      expect(t).to be_a(Transaction)
      expect(t.seeker).to eq(seeker)
      expect(t.provider).to eq(@provider)
      expect(t.rate.to_f).to be > 0
      expect(t.duration.to_f).to be > 0
    end

  end
  
  context "when adding a seeker to it's network" do
    
    it "successfully ads teh"
  end
  
end
