class Message < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  enum direction: [:to_provider, :to_seeker]
  
  TEMPLATE_FOLDER = "app/templates/"
  
  def recipient
    to_provider? ? provider : seeker
  end
  
  def sender
    to_provider? ? seeker : provider
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
  
  def add_key_val(key, value)
    @template_obj.add_key_val(key, value)
  end
  
  def process_template
    @template_obj.process
  end
  
  private
  
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
  
end
