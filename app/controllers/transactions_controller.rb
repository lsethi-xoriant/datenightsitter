class TransactionsController < ApplicationController

  def review
    @trans = Transaction.find(params["id"]) unless params["id"].nil?
    @proposed_amount = (@trans.amount > 0) ? @trans.amount : @trans.duration * @trans.rate.to_f
    @pa = @trans.seeker.payment_account
    @round_up = ( @proposed_amount / 10 ).ceil * 10   #round up to the nearest $10 
    @bump = ( @proposed_amount / 50 ).ceil * 5  #create a bump factor that starts at $5 and goes up by $5 after each $50 in transaction size
  end

  
  def update
    @trans = current_member.transactions.find(params[:id])  unless params["id"].nil?
    @provider = @trans.provider
    @seeker = current_member
    
    unless @trans.update!(trans_params) && @seeker.update!(seeker_params)  #if the transaction update fails, then return
      flash[:danger] = "Yikes! something went wrong updating your account information.  try again."
      redirect review_settle_up_path(@trans)
    end
    
    pa = @seeker.create_payment_account(params["number"], params["cvv"], params["month"], params["year"], @seeker.zip)
    
    result = @trans.authorize(@seeker.default_payment_token) unless pa.nil?  #which means the Payment Account didn't update
    
    if result
      flash[:success] = "Success!  you just paid #{@trans.provider.first_name.titleize} #{@trans.amount} and you should receive a receipt shortly."
      redirect_to(dashboard_member_path(current_member))
    else
      flash[:danger] = "Yikes! something was wrong with your credit card information.  try again."
      redirect review_settle_up_path(@trans)
    end
    
    
  end
  
  
  private
  
  def trans_params
    params.require(:transaction).permit(:amount)
  end
  
  def seeker_params
    params.require(:transaction).permit(:zip, :email)
  end
  
end
