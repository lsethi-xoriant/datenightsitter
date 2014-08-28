# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  type          :string(255)
#  provider_id   :integer
#  seeker_id     :integer
#  direction     :integer
#  subject       :string(255)
#  body          :text
#  reference_url :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  template      :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    type ""
    provider nil
    seeker nil
    sender "MyString"
    subject "MyString"
    body "MyText"
  end
end
