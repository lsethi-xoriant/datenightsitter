class SessionsController < ApplicationController

  def new
  end
  
  def create
    @member = Member.authenticate(params[:email], params[:password])
    if @member
      authorize(@member)
      redirect_to dashboard_member_path(@member), :flash => {:success => "Logged in!" }
    else
      flash[:danger] = "Invalid email or password"
      render "new"
    end
  end
    
  def destroy
    session[:member_id] = nil
    redirect_to log_in_path, :flash => {:notice => "Logged out!"}
  end

end
