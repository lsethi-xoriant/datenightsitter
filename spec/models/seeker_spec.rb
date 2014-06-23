require 'rails_helper'

RSpec.describe Seeker, :type => :model do

  context "after being created" do
    let!(:seeker) { FactoryGirl.create(:seeker) }
    
    it "is a Seeker object" do
      expect(seeker).to be_valid
      expect(seeker).to be_a(Seeker)
    end
    
  end
  
end
