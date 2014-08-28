class Provider::ProvidersController < ApplicationController
  layout 'role_layout/provider'
  skip_before_action :require_authentication, only: [:new, :create, :invited]
  respond_to :html, :json

  def profile
    @member = current_member  
  end
  
  def terms_of_use
    @member = current_member  
  end
  
  def update
    @member = current_member
    if @member.update(member_params)
      redirect_to(dashboard_member_path(@member),
                  :flash => { :success => "Account updated" })
    else
      render :profile
    end
  end
  
  def invite_parent
    @member = current_member
    @seeker = Seeker.new
  end
  
  def invited
    @seeker = Seeker.find(params[:id])
    @provider = @seeker.network.first
  end
  
  def add_seeker
    @member = current_member
    @seeker = @member.find_or_create_in_network(seeker_params)

    unless @seeker.errors.any?
      SmsMessage.createPeerToPeerMsg(@member, @seeker).invite_to_join
      redirect_to(dashboard_member_path(@member),
                  :flash => { :success => "The parent #{@seeker.full_name} has been added" })
    else
      @seeker.errors.full_messages.each do |m|
        flash[:danger] = m.to_s
      end
      render :invite_parent
    end
    
  end
  
  def dashboard
    @provider = current_member

      if @member.accepted_tou_at.nil? || @provider.accepted_tou_at < Time.parse(Rails.application.secrets.sittercity_current_tou)   #TODO FIX:  move to config file
        redirect_to provider_terms_of_use_path
      else
        
        @trans = @member.transactions.order(:started_at => :desc).paginate(:per_page => 3, :page => params[:page])
        @ttl_paid_jobs = @member.transactions.where(:status => :paid).count
        @ttl_amt = @member.transactions.where(:status => :paid).pluck(:amount_cents).reduce(0, :+) / 100.to_f
        @ttl_hrs = @member.transactions.where(:status => :paid).pluck(:duration).reduce(0, :+)
        @avg_rate = ( @ttl_hrs > 0) ? @ttl_amt / @ttl_hrs.to_f : 0
        
        render :provider_dashboard
    end
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
    start_time = Time.at(((Time.now.to_f/3600).floor-4) * 3600)
    @seeker = Seeker.new
    @transaction = Transaction.new({:started_at => start_time, :duration => 4, :rate => 10.0 }) 
    @network = @provider.network
    
    if @provider.is_a?(Provider)
      render :settle_up
    else
      redirect_to(parent_dashboard_member_path(@provider),
                  :flash => { :danger => "Your account can not open this page"})
    end
  end
  
  def submit_bill
    @provider = current_member
    @seeker = @provider.find_or_create_in_network(seeker_params)
    
    result = @provider.request_payment(@seeker, trans_params) unless @seeker.nil?
    
    if @seeker && result
      redirect_to(dashboard_member_path(@provider),
                  :flash => { :success => "Thanks! the #{@seeker.last_name.titleize} family has been notified."})
    else
      flash[:danger] = "There was something wrong with your request.  please try again"
      render :settle_up
    end
  end
  
  def date_night_availability
    @provider = current_member
    @slots = DateNightSlot.where("available_on >= ?", Date.today).paginate(:per_page => 6, :page => params[:page])
  end
  
  
  private
  
  def member_params
    params.require(:member).permit(:first_name, :last_name, :email, :password, :address, :city, :state, :zip, :type, :phone, :date_of_birth, :accepted_tou_at)
  end
  
  def trans_params
    params.require(:transaction).permit(:started_at, :duration, :rate )
  end
end