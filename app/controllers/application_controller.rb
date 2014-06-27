class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_member, :authenticate, :authenticated?, :reauthorize
  
  private
  
  def current_member
    @current_member ||= Member.find(session[:member_id]) if session[:member_id]
  end
  
  def authenticate(unique_id, password, save = false)
    member = Member.authenticate(params[:email], params[:password])
    authorize(member, save)
  end
  
  def authenticated?
    current_member.is_a? Member
  end

  def reauthorize(member)
    #should we do any other checks?
    authorize(member, false)
  end
  
  
  def authorize(member, save = false)
    if member.is_a?(Member)
      session[:member_id] = member.id
      cookies.encrypted[:member_id] = { value: member.id, expires: 1.month.from_now } if save
    end
  end

end
