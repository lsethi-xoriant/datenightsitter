class Provider < Member
  has_many :transactions
  
  def add_seeker(last_name, email, mobile)
    nil
  end
  
  def get_seeker(seeker)
    add_seeker(nil, nil, nil)
  end
  
  def request_payment(seeker, rate, started_at, duration)
    e = create_transaction(s, rate, start_at)
    e.duration = duration
    e.save
  end
  
  def create_transaction(seeker, rate, duration, started_at)
    t = transactions.create(:merchant_account_id => self.merchant_account_id)
    t.request_payment_immediately(seeker, rate, duration, started_at)
  end
  
  #get merchant account
  def merchant_account
    Braintree::MerchantAccount.find(self.merchant_account_id) unless self.merchant_account_id.nil?
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
      :master_merchant_account_id => APP_CONFIG["braintree"]["master_merchant_account_id"]
    )
    
    ma = nil
    if result.success?
      ma = result.merchant_account
      logger.debug "Creating merchant account succeeded. merchant_account.id = #{ma.id}"
      self.merchant_account_id = ma.id
      self.save
    else
      logger.debug "Creating merchant account failed.\n #{result.errors.to_s}"
      ma = result.errors
    end
    ma
  end

end