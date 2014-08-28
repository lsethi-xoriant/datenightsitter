# == Schema Information
#
# Table name: sittings
#
#  id                 :integer          not null, primary key
#  type               :string(255)
#  status             :string(255)
#  provider_id        :integer
#  seeker_id          :integer
#  started_at         :datetime
#  ended_at           :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  date_night_slot_id :integer
#

class Sitting < ActiveRecord::Base
  belongs_to :provider
  belongs_to :seeker
  
  state_machine :status, :initial => :unavailable do
    store_audit_trail :context_to_log => :calling_member_id

    state :requested
    state :available
    state :unavailable
    state :guaranteed
    state :booked
    state :completed
    state :cancelled
    state :unfilled
    state :uncompleted
    
    state :available, :unavailable, :requested do
      def status_editable?
        true
      end
      
      def status_editable_options
        ["available", "unavailable"]
      end
      
    end
    
    state all - [:available, :unavailable, :requested] do
      def status_editable?
        false
      end
    end
    
    event :set_unavailable do
      transition :available => :unavailable
      transition :cancelled => :unavailable
    end
    
    event :set_available do
      transition :guaranteed => :available
      transition :unavailable => :available
    end
    
    #sittercity can guarantee a sitter will work
    event :guarantee do
      transition :available => :guaranteed
    end
    
    event :book do
      transition [:requested, :available, :guaranteed] => :booked
    end
    
    event :complete do
      transition :booked => :completed
    end
    
    #seekers can :cancel
    event :cancel do
      transition [:requested, :guaranteed, :booked] => :cancelled
    end
    
    event :not_completed do
      transition [:available, :guaranteed, :requested] => :unfilled
      transition [:reserved, :booked] => :uncompleted
    end
    
      
  end
  
  def calling_member_id
    #current_member.id if current_member
    nil
  end
  
  
end
