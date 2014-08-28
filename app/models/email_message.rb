# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  type          :string(255)
#  provider_id   :integer
#  seeker_id     :integer
#  direction     :integer
#  subject       :string(255)
#  body          :text
#  reference_url :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  template      :string(255)
#

class EmailMessage < Message
  belongs_to :seeker
  belongs_to :provider
  enum direction: [:to_provider, :to_seeker]
  
  def dispatch
    # put your own credentials here 
    api_user = Rails.application.secrets.sendgrid_api_user
    api_key = Rails.application.secrets.sendgrid_api_key
    from_address = Rails.application.secrets.sendgrid_from_address
    
    # set up a client to talk to the Twilio REST API 
    @client = SendgridToolkit::Mail.new(api_user, api_key)
     
    @client.send_mail(:to => recipient.email,
		      :from => from_address,
		      :subject => subject,
		      :html => body)
    
  end
  
  #inherited submission types
  def send_payment_request(trans)
    super(trans)
    dispatch
  end
  
  def send_payment_confirmation(trans)
    super(trans)
    dispatch
  end

  def send_babysitting_receipt(trans)
    super(trans)
    dispatch
  end
  
  def send_verification_code(code)
    raise_error(__method__)
  end

end
