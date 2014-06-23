require 'rails_helper'

RSpec.describe Provider, :type => :model do

  context "after being created" do
    let(:provider) { FactoryGirl.create(:provider) }
    
    
    it "is a Provider object" do
      expect(provider).to be_valid
      expect(provider).to be_a(Provider)
    end

    it "it fails to create a merchant account gracefully" do
      pfail = FactoryGirl.create(:provider_fail)
      expect(pfail.merchant_account_id).to be_nil
      pfail.create_merchant_account("11431678612343", "071101307", true)
      expect(pfail.merchant_account).to be_nil
    end
  end
  
  context "and after creating a merchant account" do   
    before(:all) do
      @provider = FactoryGirl.create(:provider)
      @provider.create_merchant_account("114313413412343", "071101307", true)
    end
    
    it "has a valid merchant account" do
      expect(@provider.merchant_account_id).to be_truthy
      expect(@provider.merchant_account).to be_truthy
    end
    
    it "can request payment now" do
      seeker = FactoryGirl.create(:seeker, :phone => '+13129700557')   #this phone definitely works with twitter
      seeker.create_payment_account("4111111111111111", "333", "11","", seeker.zip)
      t = @provider.request_payment_now(seeker, (DateTime.now - (4.0 / 24.0 )), 4.5, 15)
      expect(t).to be_a(Transaction)
      expect(t.seeker).to eq(seeker)
      expect(t.provider).to eq(@provider)
      expect(t.rate).to eq(15)
      expect(t.duration).to eq(4.5)
    end

  end
  
end
