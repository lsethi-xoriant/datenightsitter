require 'rails_helper'

RSpec.describe TransactionsController, :type => :controller do

  describe "GET 'review'" do
    it "returns http success" do
      get 'review'
      expect(response).to be_success
    end
  end

  describe "POST 'complete'" do
    it "returns http success" do
      post 'complete'
      expect(response).to be_success
    end
  end

end
