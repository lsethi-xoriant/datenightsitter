class SmsMessage < Message
  belongs_to :seeker
  belongs_to :provider
  enum direction: [:to_provider, :to_seeker]
  
  def dispatch
    # put your own credentials here 
    sid = Rails.application.secrets.twilio_account_sid
    token = Rails.application.secrets.twilio_auth_token
    from_number = Rails.application.secrets.twilio_phone_number
    
    # set up a client to talk to the Twilio REST API 
    @client = Twilio::REST::Client.new sid, token 
     
    @client.account.messages.create({
    	:from => from_number, 
	:to => recipient.phone, 
	:body => body,     
    })
  end

  ##########################
  #  Inherited submissions
  ##########################
  
  def invite_to_join
    super
    dispatch
  end

  def send_payment_request(trans)
    super(trans)
    dispatch
  end

  def send_payment_confirmation(trans)
    super(trans)
    dispatch
  end

  def send_babysitting_receipt(trans)
    raise_error(__method__)
  end

  def send_verification_code(code)
    super(code)
    dispatch
  end

  ##########################
  #  class Methods
  ##########################
  
  def self.createSystemMsg(recipient)
    SmsMessage.create do |m|
      m.recipient = recipient
    end
  end
  
  def self.createPeerToPeerMsg(sender, recipient)
    SmsMessage.create do |m|
      m.sender = sender
      m.recipient = recipient
    end
    
  end
  
end
