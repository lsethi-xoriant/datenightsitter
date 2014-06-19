require 'rails_helper'

RSpec.describe UrlShortener, :type => :model do

  context "when being created" do
    before(:each) do
      url = Faker::Internet.url
      @us = UrlShortener.new(:long_url => url)
    end
    
    it "is a UrlShortener object" do
      expect(@us).to be_valid
      expect(@us).to be_a(UrlShortener)
    end
    
    it 'has a valid long_url' do
      expect(URI(@us.long_url)).to be_a(URI)
    end
    
  end
  
  context "after running shorten" do
    before(:each) do
      url = Faker::Internet.url
      @us = UrlShortener.new(:long_url => url)
      @us.shorten
    end
    
    it 'returns a valid short_url' do
      expect(URI(@us.short_url)).to be_a(URI)
    end
    
  end
    
  
  it "raises a runtime error with a bad URL" do
    @url = Faker::Name.name
    expect{UrlShortener.shorten(@url)}.to raise_error URI::InvalidURIError
    expect{UrlShortener.new(:long_url => @url)}.to raise_error URI::InvalidURIError
  end
    
  
end
