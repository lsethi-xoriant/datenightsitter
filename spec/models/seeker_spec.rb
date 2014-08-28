# == Schema Information
#
# Table name: members
#
#  id                  :integer          not null, primary key
#  type                :string(255)
#  email               :string(255)
#  phone               :string(255)
#  password_hash       :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  address             :string(255)
#  city                :string(255)
#  state               :string(255)
#  zip                 :string(255)
#  date_of_birth       :date
#  merchant_account_id :string(255)
#  payment_account_id  :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  accepted_tou_at     :datetime
#  sso_uuid            :string(255)
#

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
