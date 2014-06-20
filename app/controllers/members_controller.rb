class MembersController < ApplicationController

  def new
    @member = Member.new
  end
  
  def create
    @member = Member.new(member_params)
    if @member.save
      redirect_to(root_url,
                  :flash => { :success => "Signed up!" })
    else
      render "new"
    end
  end
  
  def update
    redirect_to current_member.members.find(params[:id]).tap { |member|
      member.update!(member_params)
    }
  end
  
  def dashboard
    @member = current_member
    render :provider_dashboard if @member.is_a? Provider
    render :seeker_dashboard if @member.is_a? Seeker
  end
  
  def provider_dashboard
    @member = current_member
    render :provider_dashboard
  end
  
  def seeker_dashboard
    @member = current_member
    render :seeker_dashboard
  end
  
  def bank_account
    @provider = current_member
    
    if @provider.is_a?(Provider)
      @fd = @provider.merchant_account_id ? @provider.merchant_account.funding_details : nil
      @routing_number = @fd ? @fd.routing_number : nil
      @account_number = @fd ? ["**********",@fd.account_number_last_4].join : nil
      render :bank_account
    else
      redirect_to(dashboard_member_path(@provider),
                  :flash => { :danger => "Your account can not add a bank account at this time."})
    end
  end
  
  def add_bank_account
    @provider = current_member
    
    if params["account_number"] &&  params["routing_number"] && params["tos"]
      @provider.create_merchant_account(params["account_number"],  params["routing_number"],  params["tos"])
      if @provider.merchant_account
        redirect_to(dashboard_member_path(@provider),
                    :flash => { :success => "Your Account successfully added a merchant account"})
      else
        flash[:danger] = "There was an error submitting your account details.  Please try again."
        redirect_to bank_account_member_path(@provider)
      end
    else
      redirect_to(bank_account_member_path(@provider),
                  :flash => { :danger => "Something was wrong with the merchant account data you supplied."})
    end
  end
  
  def settle_up
    @provider = current_member
    if @provider.is_a?(Provider)
      render :settle_up
    else
      redirect_to(parent_dashboard_member_path(@provider),
                  :flash => { :danger => "Your account can not open settle up."})
    end
  end
  
  def submit_bill
    @provider = current_member
    seeker = Seeker.find_or_create_by(:phone => params[:seeker_phone])
    seeker.update_attributes(:last_name => params[:seeker_last_name]) if seeker.last_name.nil?
    @provider.request_payment_now(seeker, params["started_at"], params["duration_hours"], params["rate"])
    redirect_to(dashboard_member_path(@provider),
                :flash => { :success => "Thanks! the #{seeker.last_name.titleize} family has been notified."})
  end
  
  private
  
  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :password, :address, :city, :state, :zip)
  end
    
end
