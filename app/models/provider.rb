class Provider < Member
  has_many :transactions
  has_many :messages
  has_and_belongs_to_many :seekers
  
  def request_payment_now(seeker, started_at, duration, rate)
    t = transactions.create(:merchant_account_id => self.merchant_account_id)
    t.request_payment_now(seeker, started_at, duration, rate)
    
    notify_seeker(seeker, t)
    
    t
  end
  

  def notify_payment_complete(trans)
    logger.debug "payment complete notification started"
    type = phone.nil? ? "EmailMessage" : "SmsMessage"
    m = messages.create(:provider => self, :seeker => trans.seeker, :direction => "to_provider", :type => type)
    m.build_payment_complete_notification(trans)
    m.dispatch
    logger.debug "#{full_name.titleize} notified of payment"
  end

  
  #get merchant account
  def merchant_account
    ma = Braintree::MerchantAccount.find(self.merchant_account_id) unless self.merchant_account_id.nil?
    ma if ma && ma.status == "active" #only return an active merchant account, otherwise nil
  end

  
  #create a merchant account for the provider
  def create_merchant_account(account_number, routing_number, tos_accepted)
    #create merchant account
    result = Braintree::MerchantAccount.create(
      :individual => {
        :first_name => self.first_name,
        :last_name => self.last_name,
        :email => self.email,
        :phone => self.phone,
        :date_of_birth => self.date_of_birth,
        :address => {
          :street_address => self.address,
          :locality => self.city,
          :region => self.state,
          :postal_code => self.zip
        }
      },
      :funding => {
        :destination => Braintree::MerchantAccount::FundingDestination::Bank,
        :account_number => account_number,
        :routing_number => routing_number
      },
      :tos_accepted => tos_accepted,
      :master_merchant_account_id => Rails.application.secrets.braintree_master_merchant_account_id
    )
    
    ma = nil
    if result.success?
      ma = result.merchant_account
      logger.debug "Creating merchant account succeeded. merchant_account.id = #{ma.id}"
      self.merchant_account_id = ma.id
      self.save
    else
      logger.debug "Creating merchant account failed."
      result.errors.each {|e|  logger.debug "error code: #{e.code};  #{e.message}"}
      ma = result.errors
    end
    ma
  end
  
  private
  
  
  def notify_seeker(seeker, trans)
    logger.debug "seeker notification started"
    type = seeker.phone.nil? ? "EmailMessage" : "SmsMessage"
    
    m = messages.create(:seeker => seeker, :direction => "to_seeker", :type => type )
    
    m.build_payment_request_notification(trans)
    m.dispatch
    logger.debug "#{seeker.last_name.titleize} family notified"
    
  end
  
  

end