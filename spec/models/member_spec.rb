require 'rails_helper'

RSpec.describe Member, :type => :model do

  context "after being created" do
    let!(:password) { Faker::Internet.password(8) }
    let!(:mem) { FactoryGirl.create(:member, :password => password) }
    
    it "is a Member object" do
      expect(mem).to be_valid
      expect(mem).to be_a(Member)
    end
    
    it "returns a contacts full name as a string" do
      expect(mem.full_name).to eq(mem.first_name + " " + mem.last_name)
    end
    
    it "has a password_hash that is a BCrypt::Password" do
      expect(mem.password_hash).to be_a(BCrypt::Password)
    end
    
    it "does not have a payment account by default" do
      expect(mem.has_payment_account?).to be_falsey
    end
    
    it "a payment account and payment method can be added" do
      mem.create_payment_account("4111111111111111", "333", "11", "2017", mem.zip)
      expect(mem.has_payment_account?).to be_truthy
    end

    it "it fails to create a payment account gracefully when the CC verification fails" do
      mem.create_payment_account("4000111111111115", "333", "11", "2017", mem.zip)
      expect(mem.has_payment_account?).to be_falsey
    end
    
    context "has an authenticate method that" do
      it "succeeds when presented with the correct password" do
        expect(Member.authenticate(mem.email, password).id).to eq(mem.id)
      end
      
      it "fails when presented with the incorrect password" do
        expect(Member.authenticate(mem.email, Faker::Internet.password(8))).to be_nil
      end
    end
    
    context "with a payment account" do
      before(:each) do
        mem.create_payment_account("4111111111111111", "333", "11", "2017", mem.zip)
      end
      
      it "will return a payment token" do
        expect(mem.payment_token).to be_truthy
      end
      
      it "will return the last 4 digits of the card will be returned" do
        expect(mem.credit_card_last_4).to eq("1111")
      end
    end
    
  end
  
  it "sets a password when none is present" do
    phone = "(312) 555-#{rand(1000..9999)}"
    mem = Member.create(:phone => phone, :password => nil)
    expect(mem).to be_a(Member)
    expect(mem.password_hash).to be_a(BCrypt::Password)
  end
  
end
