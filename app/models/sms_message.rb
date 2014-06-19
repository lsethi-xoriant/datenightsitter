class SmsMessage < Message
  
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

end
