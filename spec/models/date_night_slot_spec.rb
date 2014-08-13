require 'rails_helper'

RSpec.describe DateNightSlot, :type => :model do
  let(:dns) { FactoryGirl.create(:date_night_slot) }
  
  context "after being created" do
    
    it "is a Date Night Object object" do
      expect(dns).to be_valid
      expect(dns).to be_a(DateNightSlot)
    end
    
  end
  
end
