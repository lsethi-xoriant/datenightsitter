class Message < ActiveRecord::Base
  belongs_to :seeker
  belongs_to :provider
  enum direction: [:to_provider, :to_seeker]
  validates_presence_of :provider, :on => :create
  validates_presence_of :seeker, :on => :create
  validates_presence_of :direction, :on => :create
  
 
  def build_payment_request_notification(trans)
    self.reference_url = transaction_url(trans).to_s
    self.body = "Hey #{seeker.last_name.titleize} family, #{provider.first_name.titleize} is done babysitting. To settle up, go to: #{shortened_url}"
    self.save
  end
  
  
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
    "http://www.sittercitypay.us/transactions/#{trans.id}"
  end
  
end