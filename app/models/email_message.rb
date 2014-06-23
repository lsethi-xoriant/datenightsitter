class EmailMessage < Message
  
  def dispatch
    # put your own credentials here 
    api_user = Rails.application.secrets.sendgrid_api_user
    api_key = Rails.application.secrets.sendgrid_api_key
    
    # set up a client to talk to the Twilio REST API 
    @client = SendgridToolkit::Mail.new(api_user, api_key)
     
    @client.send_mail(:to => recipient.email,
		      :from => "aconrad@sittercity.com",
		      :subject => subject,
		      :text => body)
    
  end

end
