class Seeker < Member
  has_many :transactions
  
  def full_name
    self.first_name + " " + self.last_name
  end
  
  #get payment account from Braintree if it exists (else nil)
  def payment_account
    Braintree::Customer.find(self.payment_account_id) unless self.payment_account_id.nil?
  end
  
  
  #create a payment account with Braintree
  def create_payment_account(cc_number, cvv, expiration_date)
    result = Braintree::Customer.create(
      :first_name => self.first_name,
      :last_name => self.last_name,
      :credit_card => {
        :cardholder_name => self.full_name,
        :number => cc_number,
        :cvv => cvv,
        :expiration_date => expiration_date,
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
      logger.debug "Creating payment account failed.\n #{result.errors.to_s}"
      pa = result.errors
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