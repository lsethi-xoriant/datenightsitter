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

require 'rails_helper'

RSpec.describe SittingStatusTransition, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
