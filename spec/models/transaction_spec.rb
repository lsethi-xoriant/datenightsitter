require 'rails_helper'

RSpec.describe Transaction, :type => :model do
  
  
  context "after being created" do
    let(:trans) { FactoryGirl.create(:transaction) }
    
    
    it "is a Transaction object" do
      expect(trans).to be_valid
      expect(trans).to be_a(Transaction)
    end
    
    it "has a status of started" do
      expect(trans.started?).to be_truthy
    end
  end

  it "successfully created through a payment request" do
    trans_params = FactoryGirl.attributes_for( :trans_request_params )
    seeker = FactoryGirl.create(:seeker_with_payment_account)
    provider = FactoryGirl.create(:provider_with_merchant_account)
    t = Transaction.request_payment(provider, seeker, trans_params)
    expect(t).to be_a(Transaction)
  end
  
  context "after being requested" do
    let(:trans_params) { FactoryGirl.attributes_for( :trans_request_params ) }
    let(:seeker) { FactoryGirl.create(:seeker_with_payment_account) }
    let(:provider) { FactoryGirl.create(:provider_with_merchant_account) }
    
    before(:each) do
      @trans = Transaction.request_payment(provider, seeker, trans_params)
    end
    
    it "has a status of requested" do
      expect(@trans.requested?).to be_truthy
    end

    it "has a merchant account" do
      expect(@trans.has_merchant_account?).to be_truthy
    end
    
    it "has a seeker" do
      expect(@trans.seeker).to be_a(Seeker)
    end
    
    it "has a provider" do
      expect(@trans.provider).to be_a(Provider)
    end
    
    it "can authorize and pay the transaction" do
      trans_pay_params = FactoryGirl.attributes_for(:trans_pay_params )
      @trans.authorize_and_pay(@trans.seeker.payment_token, trans_pay_params)
      expect(@trans.paid?).to be_truthy
    end
  end
  
  context "after being authorized and paid"  do
    let(:trans) { FactoryGirl.create(:trans_requested)}
    let(:trans_params) { FactoryGirl.attributes_for(:trans_pay_params ) } 
    
    before(:each) do
      trans.authorize_and_pay(trans.seeker.payment_token, trans_params)
    end
    
    it "has a status of paid" do
      expect(trans.status).to eq("paid")
      expect(trans.paid?).to be_truthy
    end
    
    it "has a payment token" do
      expect(trans.has_payment_token?).to be_truthy
    end

    it "has valid amounts" do
      expect(trans.has_valid_amounts?).to be_truthy
    end

    it "has valid details" do
      expect(trans.all_details_valid?).to be_truthy
    end
    
    it "has a valid processor transaction"
  end
  
  
  
end


