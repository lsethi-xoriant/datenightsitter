class SessionsController < ApplicationController

  skip_before_action :require_authentication, only: [:new, :create]

  def new
      @member = Member.find_by_id(cookies.encrypted[:member_id]) if cookies.encrypted[:member_id]
      if @member
        reauthorize(@member)
        redirect_to dashboard_member_path(@member)
      else
        render
      end
  end
  
  def create
    authenticate_member(params[:email], params[:password], false)
    
    if member_authenticated?
      redirect_to dashboard_member_path(current_member), :flash => {:success => "Logged in!" }
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
