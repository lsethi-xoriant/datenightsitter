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
  
  def message_type_preference
    phone.nil? ? EmailMessage.name : SmsMessage.name
  end


  #to sanitized hash
  def to_h
    temp_hash = attributes
    temp_hash.delete('password_hash')
    temp_hash.delete('merchant_account_id')
    temp_hash.delete('payment_account_id')
    temp_hash.merge!(Hash['credit_card_last_4',credit_card_last_4]) if has_payment_account?
    temp_hash
  end
  
  def network
    raise "not implemented"
  end
  
  # look for a member and either add them to our network, or create them.
  # to find a member, an :id, :phone, or :email param needs to be provided
  def find_or_create_in_network(params)
    #find the member if he exists
    @member = Member.find_by_id(params[:id]) unless params[:id].nil?
    @member ||= Member.find_by_phone(params[:phone]) unless params[:phone].nil?
    @member ||= Member.find_by_email(params[:email]) unless params[:email].nil?
    
    if @member
      #add existing member to network if necessary
      @member.update!(params)
      network << @member unless network.find_by_id(@member.id).nil?
    else
      #otherwise create
      @member = network.create(params)
    end
    @member
  end
  
  #############################
  #  MERCHANT ACCOUNT FEATURES
  #############################

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
  
  
  def self.search_by(field, val)
    case field
    when :phone, "phone"
      search_field = 'phone'
    when :last_name, "last_name"
      search_field = "last_name"
    else
      search_field = "nil"
    end
    
    where("#{search_field} like ?", [val.to_s,"%"].join)
  end
  
  protected

  def check_password
    self.password_hash ||= Password.create(SecureRandom.hex(5).to_s)
  end
  
  
end
