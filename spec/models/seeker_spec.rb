require 'rails_helper'

RSpec.describe Seeker, :type => :model do

  context "after being created" do
    let!(:seeker) { FactoryGirl.create(:seeker) }
    
    it "is a Seeker object" do
      expect(seeker).to be_valid
      expect(seeker).to be_a(Seeker)
    end
    
    it "can create a payment account with payment method" do
      expect(seeker.payment_account_id).to be_nil
      seeker.create_payment_account("4111111111111111", "333", "11/2017")
      expect(seeker.payment_account_id).to be_truthy
      expect(seeker.default_payment_token).to be_truthy
    end

    it "it fails to create a payment account gracefully when the CC verification fails" do
      seeker.payment_account_id = nil
      expect(seeker.payment_account).to be_nil
      seeker.create_payment_account("4000111111111115", "333", "11/2017")
      expect(seeker.payment_account_id).to be_nil
      expect(seeker.default_payment_token).to be_nil
    end
  end
  
end
