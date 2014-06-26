class Transaction < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  
  monetize :amount_cents
  monetize :service_fee_amount_cents
  monetize :rate_cents
  
  #set/manage status logic
  state_machine :status, :initial => :started do
    before_transition :on => :process_payment, :do => :submit_payment
    
    state :started
    state :requested
    state :validated
    state :authorized
    state :submitable
    state :paid
    state :failed
    
    
    event :update_submission_status do
      transition any - [:paid] => :submitable, :if => :all_details_valid?
      transition any - [:paid] => :authorized, :if => :has_payment_token?
      transition any - [:paid] => :validated, :if => :has_valid_amounts?
      transition any - [:paid] => :requested, :if => :has_merchant_account?
      transition any => same
    end
    
    event :submit_request do
      transition any - [:paid,:requested] => :requested, :if => :has_merchant_account?
      transition :requested => same
    end
    
    event :authorize do
      transition all - [:paid] => :authorized, :if => :has_payment_token?
    end
    
    event :process_payment do
      transition :submitable => :failed, :if => :transaction_processed?
      transition :submitable => :paid
    end
    
  end
  
  def has_payment_token?
    !payment_token.nil?
  end
  
  def has_merchant_account?
    !merchant_account_id.nil?
  end
  
  #helper method to determine if amounts are valid for submission
  def has_valid_amounts?
    amount_cents > 0 && service_fee_amount_cents >= 0
  end
    
  #helper method to determine if something is submitable
  def all_details_valid?
    has_payment_token? && has_merchant_account? && has_valid_amounts?
  end
  
  def transaction_processed?
    !processor_transaction_id.nil?
  end
  
  #helper function to 
  def estimated_rate
    (paid?) ? (amount.to_f / duration.to_f) : (rate.to_f)
  end
  
  def estimated_amount
    (paid?) ? (amount.to_f) : (rate.to_f * duration.to_f)
  end

  
  #sanitized_hash
  def to_h
    temp_hash = attributes
    temp_hash.delete('merchant_account_id')
    temp_hash.delete('payment_token')
    temp_hash.delete('amount_cents')
    temp_hash.delete('amount_currency')
    temp_hash.delete('rate_cents')
    temp_hash.delete('rate_currency')
    temp_hash.delete('service_fee_amount_cents')
    temp_hash.delete('service_fee_amount_currency')
    temp_hash.merge!(Hash['amount',amount.to_f])
    temp_hash.merge!(Hash['rate',rate.to_f])
    temp_hash.merge!(Hash['service_fee_amount',service_fee_amount.to_f])
    temp_hash.merge!(Hash['duration',duration.to_f])
  end
  
  def to_pretty_h
    temp_hash = to_h
    temp_hash.merge!(Hash['amount',amount.format_with_settings])
    temp_hash.merge!(Hash['rate',rate.format_with_settings])
    temp_hash.merge!(Hash['service_fee_amount',service_fee_amount.format_with_settings])
    temp_hash.merge!(Hash['duration',duration.to_f])
    
  end

  
  def transaction_from_processor
    Braintree::Transaction.find(self.processor_transaction_id) unless self.processor_transaction_id.nil?
  end
  
  #request payment
  def request_payment(seeker, trans_params)
    update_attributes(trans_params.merge({:seeker_id => seeker.id}))
    self.submit_request
    send_request_notification
  end

  #authorize payment and pay if all items are complete
  def authorize_and_pay(payment_token, trans_params)
    update_attributes(trans_params.merge({:payment_token => payment_token}))

    update_submission_status   #update status with payment token
    
    process_payment if self.submitable?
    
    send_completion_notifications if paid?   #send notifications

    paid?   #return true if paid
  end
  
  #submit transaction if possible
  def submit_payment
    if submitable?
      process_transaction 
    else
      raise "Not a valid Transaction to submit"
    end
  end
  
  
  ##########################
  #
  #  Communications
  #
  ##########################
  
  #send request to seeker for payment
  def send_request_notification
    logger.debug "seeker notification started"
    m = Message.create(:provider => provider, :seeker => seeker, :direction => "to_seeker", :type => seeker.message_type_preference )
    m.send_payment_request(self)
    logger.debug "#{seeker.last_name.titleize} family notified"
  end
  
  #sends notifications to both parties that the payment has processed successfully
  def send_completion_notifications
    logger.debug "completion notifications started"
    
    #send confirmation to sitter
    m = Message.create(:provider => provider, :seeker => seeker, :direction => "to_provider", :type => provider.message_type_preference )
    m.send_payment_confirmation(self)
    logger.debug "#{provider.full_name.titleize} notified"    
    
    #send email receipt to parent
    m = EmailMessage.create(:seeker => seeker, :provider => provider, :direction => "to_seeker")
    m.send_babysitting_receipt(self)
    logger.debug "#{seeker.last_name.titleize} notified"
  end

  
  
  ##########################
  #
  #  Classs methods
  #
  ##########################
  
  def self.request_payment(provider, seeker, trans_params)
    t = Transaction.create(:provider => provider, :merchant_account_id => provider.merchant_account_id)
    t.request_payment(seeker, trans_params)
    t
  end
  
  ##########################
  #
  #  Private
  #
  ##########################
  private
  
  #process the transaction
  def process_transaction
    result = Braintree::Transaction.sale(
      :amount => self.amount,
      :merchant_account_id => self.merchant_account_id,
      :payment_method_token => self.payment_token,
      :options => {
        :submit_for_settlement => true
      },
      :service_fee_amount => self.service_fee_amount
    )

    t = nil
    if result.success?
      t = result.transaction
      logger.debug "Processing transaction succeeded. transaction.id = #{t.id}"
      self.processor_transaction_id = t.id
      self.save
    else
      logger.debug "Processing transaction failed failed.\n #{result.errors.to_s}"
      t = result.errors
    end
    t
  end
  #end process_transaction
  
end
