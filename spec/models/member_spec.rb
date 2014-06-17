require 'rails_helper'

RSpec.describe Member, :type => :model do

  it "is invalid without an email address" do
    expect { FactoryGirl.create(:member, :email => nil) }.to raise_error ActiveRecord::RecordInvalid
  end
  
  it "is invalid without a phone number" do
    expect { FactoryGirl.create(:member, :phone => nil) }.to raise_error ActiveRecord::RecordInvalid
  end
  
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
  
    context "has an authenticate method that" do
      it "succeeds when presented with the correct password" do
        expect(Member.authenticate(mem.email, password).id).to eq(mem.id)
      end
      
      it "fails when presented with the incorrect password" do
        expect(Member.authenticate(mem.email, Faker::Internet.password(8))).to be_nil
      end
    end

  end
  
end
