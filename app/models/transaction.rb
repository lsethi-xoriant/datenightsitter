class Transaction < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  
  monetize :amount_cents
  monetize :service_fee_amount_cents
  monetize :rate_cents
  
  state_machine :status, :initial => :started do
    
    state :started
    state :requested
    state :authorized
    state :paid
    state :failed
    
    event :submit_request do
      transition any - [:paid,:requested] => :requested
      transition :requested => same
    end
    
    event :authorize_payment do
      transition all - [:paid] => :authorized, :if => :has_payment_token?
    end
    
    event :complete_payment do
      transition all => :paid
    end
    
    event :fail_payment do
      transition all - :paid => :failed
    end
    
  end
  
  def has_payment_token?
    !payment_token.nil?
  end
  
  
  def authorize(payment_token)
    self.payment_token = payment_token
    self.authorize_payment
    t = submit
    send_completion_notifications if t   #send notifications
    t
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
  
  #request payment to as soon as possible
  def request_payment_now(seeker, started_at, duration, rate)
    update_attributes(:seeker => seeker,
                      :started_at => started_at,
                      :duration => duration,
                      :rate => rate)
    self.submit_request
    send_request_notification
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
  #  Private
  #
  ##########################
  private
  
  #submit transaction if possible
  def submit
    if submitable?
      process_transaction 
    else
      raise "Not a valid Transaction to submit"
    end
  end
  
  def submitable?
    authorized? && !amount_cents.nil? && !service_fee_amount_cents.nil? 
  end
  
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
      self.complete_payment
      self.save
    else
      logger.debug "Processing transaction failed failed.\n #{result.errors.to_s}"
      t = result.errors
      self.fail_payment
    end
    t
  end
  #end process_transaction
  
end
