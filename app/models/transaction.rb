class Transaction < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  
  monetize :amount_cents
  monetize :service_fee_amount_cents
  monetize :rate_cents
  
  def authorize(payment_token)
    self.payment_token = payment_token
    t = self.submit
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
  
  
  def authorized?
    !payment_token.nil?
  end
  
  def submitable?
    !payment_token.nil? && !amount_cents.nil? && !service_fee_amount_cents.nil? 
  end
  
  #submit transaction if possible
  def submit
    if submitable?
      process_transaction 
    else
      raise "Not a valid Transaction to submit"
    end
  end
  #end submit
  
  def transaction_from_processor
    Braintree::Transaction.find(self.processor_transaction_id) unless self.processor_transaction_id.nil?
  end
  
  #request payment to as soon as possible
  def request_payment_now(seeker, started_at, duration, rate)
    update_attributes(:seeker => seeker,
                      :started_at => started_at,
                      :duration => duration,
                      :rate => rate)
    
    send_request_notification
  end
  
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
    logger.debug "#{provider.full_name.titleize}notified"    
    
    #send email receipt to parent
    m = EmailMessage.create(:seeker => seeker, :provider => provider, :direction => "to_seeker")
    m.send_babysitting_receipt(self)
    logger.debug "#{seeker.last_name.titleize} notified"
  end
  
  private
  
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
