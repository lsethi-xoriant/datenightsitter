class Seeker < Member
  has_many :transactions
  
  #get payment account from Braintree if it exists (else nil)
  def payment_account
    Braintree::Customer.find(self.payment_account_id) unless self.payment_account_id.nil?
  end
  
  
  #create a payment account with Braintree
  def create_payment_account(cc_number, cvv, expiration_month, expiration_year, zipcode)
    result = Braintree::Customer.create(
      :last_name => self.last_name,
      :credit_card => {
        :billing_address => {
          :postal_code => zipcode
        },
        :number => cc_number,
        :cvv => cvv,
        :expiration_month => expiration_month,
        :expiration_year => expiration_year,
        :options => {
          :verify_card => true
        }
      }
    )
    
    pa = nil
    if result.success?
      pa = result.customer
      logger.debug "Creating payment account succeeded. payment_account.id = #{pa.id}"
      self.payment_account_id = pa.id
      self.save
    else
      logger.debug "Creating payment account failed."
      result.errors.each {|e|  logger.debug "error code: #{e.code};  #{e.message}"}
    end
    pa
  end
  #end create_payment_account
  
  #get the default payment token for the account (else nil)
  def default_payment_token
    default_token = nil
    pa = payment_account
    if pa
      pa.credit_cards.each do |e|
        default_token = e.token if e.default?
      end
    end
    default_token
  end
  #end default_payment_token
  
end