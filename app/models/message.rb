class Message < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  enum direction: [:to_provider, :to_seeker]
  
  TEMPLATE_FOLDER = "app/templates/"
  
  def recipient
    to_provider? ? provider : seeker
  end
  
  def recipient=(member)
    self.provider = member if member.is_a?(Provider)
    self.seeker = member if member.is_a?(Seeker)
    self.direction = member.is_a?(Provider) ? "to_provider" : "to_seeker"
  end
  
  def sender
    to_provider? ? seeker : provider
  end

  def sender=(member)
    self.provider = member if member.is_a?(Provider)
    self.seeker = member if member.is_a?(Seeker)
  end


  
  def shortened_url
    UrlShortener.shorten(reference_url).short_url
  end
  
  def transaction_url(trans)
    "http://www.sittercitypay.us/settle_up/#{trans.id}/review"
  end
  
  def dashboard_url(member)
    "http://www.sittercitypay.us/members/#{member.id}/dashboard"
  end
  
  def invitation_url(member)
    "http://www.sittercitypay.us/members/#{member.id}/invited"
  end
  
  ##########################
  #  class Methods
  ##########################
  

  
  ##########################
  #  Private Methods
  ##########################
  
  private
  def invite_to_join
    set_template __method__    #filename send_babysitting_receipt.email
    self.reference_url = invitation_url(recipient)
    
    #add values to the template
    add_key_val("recipient",recipient.to_h)
    add_key_val("sender",sender.to_h)
    add_key_val("shortened_url", shortened_url)
    
    self.update_attributes(:subject => 'Verify Account', :body => process_template)
  end

  
  def send_verification_code(code)
    set_template __method__    #filename send_babysitting_receipt.email
    
    #add values to the template
    add_key_val("code",code)
    
    self.update_attributes(:subject => 'Verify Account', :body => process_template)
  end
  
  
  def send_payment_request(trans)
    self.reference_url = transaction_url(trans).to_s
    set_template __method__    #filename send_babysitting_receipt.email
    logger.debug "getting template #{template}"
    
    #add values to the template
    add_key_val("transaction",trans.to_pretty_h)  #format dollars correctly
    add_key_val("recipient",trans.seeker.to_h)
    add_key_val("sender",trans.provider.to_h)
    add_key_val("shortened_url", shortened_url)
    
    self.subject = 'Settling up wtih your Babysitter'
    self.body = process_template
    self.save
  end
  
  def send_babysitting_receipt(trans)
    set_template __method__    #filename send_babysitting_receipt.email
    logger.debug "getting template #{template}"
    
    #add values to the template
    add_key_val("transaction",trans.to_pretty_h)  #format dollars correctly
    add_key_val("recipient",trans.seeker.to_h)
    add_key_val("sender",trans.provider.to_h)
    
    self.subject = 'Babysitting Receipt'
    self.body = process_template
    self.save
    
  end
  
  def send_payment_confirmation(trans)
    self.reference_url = dashboard_url(trans).to_s
    set_template __method__    #filename send_babysitting_receipt.email
    logger.debug "getting template #{template}"

    #add values to the template
    add_key_val("transaction",trans.to_pretty_h)  #format dollars correctly
    add_key_val("sender",trans.seeker.to_h)
    add_key_val("recipient",trans.provider.to_h)
    add_key_val("shortened_url", shortened_url)
    
    self.subject = 'Payment Confirmation'
    self.body = process_template
    self.save
    
  end
  
  
  def set_template(template_name)
    self.template = template_name
    @template_obj = Template.new
    @template_obj.template_filepath = get_template_filepath
  end
  
  def get_template_filepath
    message_type = self.class.name.downcase.split('message').first
    [TEMPLATE_FOLDER, self.template,".",message_type].join   # eg app/templates/function.type file path
  end
  
  def add_key_val(key, value)
    @template_obj.add_key_val(key, value)
  end
  
  def process_template
    @template_obj.process
  end
  
  def raise_error(method_name)
    raise "#{method_name.upcase}() is not implemented in this class #{self.class}"
  end
  
end
