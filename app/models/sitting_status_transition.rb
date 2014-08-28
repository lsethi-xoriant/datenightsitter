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

class SittingStatusTransition < ActiveRecord::Base
  belongs_to :sitting
end
