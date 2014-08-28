# == Schema Information
#
# Table name: members
#
#  id                  :integer          not null, primary key
#  type                :string(255)
#  email               :string(255)
#  phone               :string(255)
#  password_hash       :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  address             :string(255)
#  city                :string(255)
#  state               :string(255)
#  zip                 :string(255)
#  date_of_birth       :date
#  merchant_account_id :string(255)
#  payment_account_id  :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  accepted_tou_at     :datetime
#  sso_uuid            :string(255)
#

class Provider < Member
  has_many :transactions, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_many :sittings
  has_and_belongs_to_many :seekers
  
  #alias to support searching network for connections
  def network
    self.seekers
  end
  
  def request_payment(seeker, trans_params)
    Transaction.request_payment(self, seeker, trans_params)
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
  
end
