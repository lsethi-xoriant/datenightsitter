class UrlShortener
  include ActiveModel::Model
  attr_reader :long_url, :short_url, :shortened_at
  
  SHORTENER_API = "https://www.googleapis.com/urlshortener/v1/url"

  
  #setter method to ensure we have a URL
  def long_url=(url)
    @long_url = URI(url).to_s 
  end
  
  #shortens a long url using Google's shortener tool
  def shorten
    raise "long_url not set" if @long_url.nil?
    
    api_key = Rails.application.secrets.google_api_key
    payload = {"longUrl" => @long_url.to_s }
    
    begin
      response = RestClient.post( SHORTENER_API, payload.to_json, :params => {:key => api_key}, :content_type => :json )
    rescue => e
      Rails.logger.debug "response.code:  #{e.response.code};  #{e.response}"
    end
    
    if response
      data = JSON.parse(response.body)
      
      @short_url = data["id"]
      @shortened_at = DateTime.now
      data["id"]
    else
      nil
    end
  end

  # Class methods to 
  def self.shorten(url)
    us = UrlShortener.new(:long_url =>url)
    
    us.shorten ? us : nil  #if shorten succeeds, return object
  end

end