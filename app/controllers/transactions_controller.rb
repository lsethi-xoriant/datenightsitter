class TransactionsController < ApplicationController

  def review
    @trans = Transaction.find(params["id"]) unless params["id"].nil?
    @proposed_amount = (@trans.amount.to_f > 0) ? @trans.amount.to_f : (@trans.duration * @trans.rate.to_f)
    @seeker = @trans.seeker
    @round_up = ( @proposed_amount / 10 ).ceil * 10   #round up to the nearest $10 
    @bump = ( @proposed_amount / 50 ).ceil * 5  #create a bump factor that starts at $5 and goes up by $5 after each $50 in transaction size
  end
  
  def update
    @trans = Transaction.find(params[:id])  unless params["id"].nil?
    @provider = @trans.provider
    @seeker = @trans.seeker
    
    #update seeker's information
    if params[:seeker]
      unless @seeker.update!(seeker_params)
      flash[:danger] = "Yikes! something went wrong updating your email and zip code.  try again."
        redirect_to review_settle_up_path(@trans)
      end
    end
    
    unless params[:use_card_on_file]
      @seeker.create_payment_account(params["number"], params["cvv"], params["month"], params["year"], @seeker.zip)
    end
    
    @trans.authorize_and_pay(@seeker.payment_token, trans_params) if @seeker.has_payment_account?  #which means the Payment Account didn't update
    
    if @trans.paid?
      flash[:success] = "Success! You just paid #{@trans.provider.first_name.titleize} #{@trans.amount} and you should receive a receipt shortly."
      redirect_to root_path
    else
      flash[:danger] = "Yikes! something was wrong with your credit card information.  try again."
      redirect_to review_settle_up_path(@trans)
    end
    
  end
  
  def resend_request
    @trans = Transaction.find(params[:id])
    @trans.send_request_notification
    flash[:success] = "Your request was resent to the #{@trans.seeker.last_name.titleize} family"
    redirect_to dashboard_member_path(current_member)
  end
  
  private 
  
  def trans_params
    params.require(:transaction).permit(:amount)
  end
  
  def seeker_params
    params.require(:seeker).permit(:zip, :email)
  end
  
end
