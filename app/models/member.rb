class Member < ActiveRecord::Base
  include BCrypt
  validates_format_of :email, :allow_nil => true, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_uniqueness_of :email, :allow_nil => true
  validates_uniqueness_of :phone, :allow_nil => true

  
  before_validation :check_password
  
  
  def password
    @password ||= Password.new(password_hash)
  end
  
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  
  def phone=(new_phone)
    write_attribute(:phone, new_phone.gsub(/\D/, '')) unless new_phone.nil?
  end
  
  def full_name
    [first_name, last_name].join(" ")
  end


  #determines if there is a merchant account
  def has_merchant_account?
    !merchant_account_id.nil?
  end
  
  #############################
  #  PAYMENT ACCOUNT FEATURES
  #############################

  #determines if there is a payment account
  def has_payment_account?
    !payment_account_id.nil?
  end
  
  
  #get payment account from Braintree if it exists (else nil)
  def payment_account
    Braintree::Customer.find(self.payment_account_id) if has_payment_account?
  end
  
  #gets the  payment token for the default payment method
  def payment_token
      payment_account.default_credit_card.token if has_payment_account?
  end
  
  #gets the last 4 digits of the default payment method
  def credit_card_last_4
      payment_account.default_credit_card.last_4 if has_payment_account?
  end
  
  #create a payment account with Braintree;  ONLY A SEEKER CAN CURRENTLY CREATE A PAYMENT ACCOUNT
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


  #############################
  #  CLASS METHODS
  #############################

  
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == password
      user
    else
      nil
    end
  end
  
  
  protected

  def check_password
    self.password_hash ||= Password.create(SecureRandom.hex(5).to_s)
  end
  
  
end
