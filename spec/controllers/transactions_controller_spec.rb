require 'rails_helper'

RSpec.describe TransactionsController, :type => :controller do

  describe "GET 'review'" do
    context "with a valid transaction" do
      let(:trans) { FactoryGirl.create(:trans_requested)}
      
      subject{ get :review, :id => trans }
      
      it "returns http success" do
        expect(subject).to be_success
      end
      
      it "displays review page" do
        expect(subject).to render_template(:review)
      end
    end
  end

  describe "PUT 'update'" do
    context "with a valid transaction" do
      let(:trans) { FactoryGirl.create(:trans_requested)}
      let(:trans_pay_params) { FactoryGirl.attributes_for(:trans_pay_params) }
      let(:seeker_trans_update) { FactoryGirl.attributes_for(:seeker_trans_update)}
      
      before(:each) do
        post :update, :id => trans, :transaction => trans_pay_params, :seeker => seeker_trans_update,
                        :number => "4111111111111111", :cvv => "134", :month => "05", :year => "2015"    #NOTE, not using Braintree's CSE;  actual form does!
      end
      
      it "returns http success" do
        expect(response).to redirect_to(:root)
      end
      
      it "to have a payment token" do
        trans.reload
        expect(trans.payment_token).to be_truthy
      end
      
    end
  end

end
