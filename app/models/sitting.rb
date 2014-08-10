class Sitting < ActiveRecord::Base
  belongs_to :provider
  belongs_to :seeker
  
  
  
  state_machine :status, :initial => :requested do
    store_audit_trail :context_to_log => :calling_member_id

    state :requested
    state :available
    state :unavailable
    state :guaranteed
    state :reserved
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
    
    event :toggle_availability do
      transition :unavailable => :available
      transition :available => :unavailable
    end
    
    #sittercity can guarantee a sitter will work
    event :guarantee do
      transition :available => :guaranteed
    end
    
    event :book do
      transition [:requested, :available, :guaranteed, :reserved] => :booked
    end
    
    event :complete do
      transition :booked => :completed
    end
    
    #seekers can :cancel
    event :cancel do
      transition [:requested, :available, :guaranteed, :booked] => :cancelled
    end
    
    #providers can :rescind
    event :rescind do
      transition [:available, :guaranteed, :reserved, :booked] => :unavailable
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
