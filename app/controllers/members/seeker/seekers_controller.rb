module Members
  module Seeker
    class SeekersController < ApplicationController
      layout 'seeker'
      skip_before_action :require_authentication, only: [:new, :create, :invited]
      respond_to :html, :json

      def profile
        @seeker = current_member  
      end
      
      def terms_of_use
        @seeker = current_member  
      end
      
      def update
        @seeker = current_member
        if @seeker.update(member_params)
          redirect_to(dashboard_member_path(@seeker),
                      :flash => { :success => "Account updated" })
        else
          render :profile
        end
      end
      
      def dashboard
        @seeker = current_member
          if @seeker.accepted_tou_at.nil? || @seeker.accepted_tou_at < Time.parse(Rails.application.secrets.sittercity_current_tou)   #TODO FIX:  move to config file
            redirect_to provider_terms_of_use_path
          else
            
            @trans = @seeker.transactions.order(:started_at => :desc).paginate(:per_page => 3, :page => params[:page])
            @ttl_paid_jobs = @seeker.transactions.where(:status => :paid).count
            @ttl_amt = @seeker.transactions.where(:status => :paid).pluck(:amount_cents).reduce(0, :+) / 100.to_f
            @ttl_hrs = @seeker.transactions.where(:status => :paid).pluck(:duration).reduce(0, :+)
            @avg_rate = ( @ttl_hrs > 0) ? @ttl_amt / @ttl_hrs.to_f : 0
            
        end
      end
      
      def bank_account
       @seeker = current_member
        
        if @seeker.is_a?(Provider)
           @fd = @seeker.merchant_account_id ? @seeker.merchant_account.funding_details : nil
           @routing_number = @fd ? @fd.routing_number : nil
           @account_number = @fd ? ["**********",@fd.account_number_last_4].join : nil
           render :bank_account
        else
          if@seeker.is_a?(Member)
            redirect_to(dashboard_member_path(@seeker),
                        :flash => { :danger => "Your account can not add a bank account at this time."})
          else
            redirect_to(log_in_path,
                        :flash => { :danger => "Please Log In."})
          end
        end
      end
      
      def add_bank_account
       @seeker = current_member
        
        if params["account_number"] && params["routing_number"] && params["tos"]
         @seeker.create_merchant_account(params["account_number"],  params["routing_number"],  params["tos"])
          if@seeker.has_merchant_account?
            redirect_to(dashboard_member_path(@seeker),
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
      
      private
      
      def member_params
        params.require(:member).permit(:first_name, :last_name, :email, :password, :address, :city, :state, :zip, :type, :phone, :date_of_birth, :accepted_tou_at)
      end
      
      def trans_params
        params.require(:transaction).permit(:started_at, :duration, :rate )
      end
    end
  end
end