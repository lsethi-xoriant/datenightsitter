class SessionsController < ApplicationController

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
    authenticate(params[:email], params[:password], false)
    
    if authenticated?
      redirect_to dashboard_member_path(current_member), :flash => {:success => "Logged in!" }
    else
      flash[:danger] = "Invalid email or password"
      render "new"
    end
  end
    
  def destroy
    session[:member_id] = nil
    cookies.delete( :member_id )
    redirect_to log_in_path, :flash => {:notice => "Logged out!"}
  end
  
  def forgot_password
  end
  
  def verify_member
      @member = Member.find_by_phone(params[:phone])
      @member ||= Member.find_by_email(params[:email])
      
      if  @member
          #create and save random password
          pass = SecureRandom.random_number(900000)+ 100000   #create a random 6 digit number
          session[:verification_token] = BCrypt::Password.create(pass)
          
          SmsMessage.createSystemMsg(@member).send_verification_code(pass)
          
          render
      else
        redirect_to forgot_password_sessions_path, :flash => {:danger => "Sorry, we couldn't find your account."}
      end
      
      #send request
  end
  
  def change_password
      token = BCrypt::Password.new(session[:verification_token])
      @member = Member.find(params[:member_id])
      
      if token == params[:code]
        @member.update_attributes(:password => params[:password])
        authenticate(@member.email, params[:password])
        redirect_to dashboard_member_path(@member), :flash => {:success => "Your password has been reset."}
      else
        redirect_to forgot_password_sessions_path, :flash => {:danger => "Sorry, something went wrong.  Try again"}
      end
  end

end
