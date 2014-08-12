class SessionsController < ApplicationController

  skip_before_action :require_authentication, only: [:new, :create]

  def new
  end
  
  def create
    authenticate_member(params[:email], params[:password], false)
    
    if member_authenticated?
      if current_member.nil?   #then the user is a SC member, but not a date night membe
        Member.create_from_sittercity_account(current_sittercity_account)
        redirect_to profile_member_path(current_member), :flash => {:success => "Date Night Account created" }
      else
        redirect_to dashboard_member_path(current_member), :flash => {:success => "Logged in!" }
      end
    else
      flash[:danger] = "Invalid email or password"
      render "new"
    end
  end
    
  def destroy
    session[:sittercity_account] = nil
    redirect_to log_in_path, :flash => {:notice => "Logged out!"}
  end

  
end
