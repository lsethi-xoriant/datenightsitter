# == Schema Information
#
# Table name: sitting_status_transitions
#
#  id                :integer          not null, primary key
#  sitting_id        :integer
#  event             :string(255)
#  from              :string(255)
#  to                :string(255)
#  calling_member_id :integer
#  created_at        :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sitting_status_transition do
    sitter nil
    event "MyString"
    from "MyString"
    to "MyString"
    created_at "2014-08-08 00:28:16"
  end
end
