class MembersController < ApplicationController
  respond_to :html, :json

  def new
    @member = Member.new
  end
  
  def create
    @member = Member.new(member_params)
    if @member.save
      authorize(@member)
      redirect_to(dashboard_member_path(@member),
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
      if @provider.is_a?(Member)
        redirect_to(dashboard_member_path(@provider),
                    :flash => { :danger => "Your account can not add a bank account at this time."})
      else
        redirect_to(log_in_path,
                    :flash => { :danger => "Please Log In."})
      end
    end
  end
  
  def add_bank_account
    @provider = current_member
    
    if params["account_number"] && params["routing_number"] && params["tos"]
      @provider.create_merchant_account(params["account_number"],  params["routing_number"],  params["tos"])
      if @provider.has_merchant_account?
        redirect_to(dashboard_member_path(@provider),
                    :flash => { :success => "Your Account successfully added a merchant account"})
      else
        flash[:danger] = "There was an error submitting your account details.  Please try again."
        render :bank_account
      end
    else
      flash[:danger] = "Something was wrong with the bank account data you supplied."
      render :bank_account
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
  
  
  def autocomplete_search_connections_by_phone
    @member = current_member
    @members = search_connections(@member, :phone, params[:term])
    respond_with(@members)
  end
  
  def autocomplete_search_connections_by_last_name
    @member = current_member
    @members = search_connections(@member, :last_name, params[:term])
    respond_with(@members)
  end
  
  private
  
  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :password, :address, :city, :state, :zip, :type, :phone, :date_of_birth)
  end
  
  
  def search_connections(member, field, val)
    if member.is_a?(Provider)
      member.seekers.search_by(field, val)
    else
      member.providers.search_by(field, val)
    end
  end
    
end
