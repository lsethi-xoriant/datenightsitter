class Transaction < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  
  monetize :amount_cents
  monetize :service_fee_amount_cents
  monetize :rate_cents
  
  def authorize(payment_token, amount)
    self.payment_token = payment_token
    self.amount = amount
    self.submit
  end
  

  def authorized?
    !payment_token.nil?
  end
  
  def submitable?
    !payment_token.nil? && !amount_cents.nil? && !service_fee_amount_cents.nil? 
  end
  
  #
  def submit
    if submitable?
      process_transaction 
    else
      contact_seeker unless authorized?
    end
  end
  
  def transaction_from_processor
    Braintree::Transaction.find(self.processor_transaction_id) unless self.processor_transaction_id.nil?
  end
  
  
  def request_payment_immediately(seeker, started_at, duration, rate)
    update_attributes(:seeker => seeker,
                      :started_at => started_at,
                      :duration => duration,
                      :rate => rate)
    contact_seeker
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
      logger.debug "Creating merchant account succeeded. merchant_account.id = #{t.id}"
      self.processor_transaction_id = t.id
      self.save
    else
      logger.debug "Creating merchant account failed.\n #{result.errors.to_s}"
      t = result.errors
    end
    t
  end
  
  def contact_seeker
    logger.debug "#{seeker.last_name.titleize} family contacted."
  end
end
