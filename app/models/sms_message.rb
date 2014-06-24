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
    raise "#{__method__.upcase}() is not implemented in this clas #{self.class}"
  end


  
end
