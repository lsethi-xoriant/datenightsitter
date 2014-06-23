class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_member
  helper_method :member_signed_in?
  helper_method :authorize
  
  private
  
  def current_member
    @current_member ||= Member.find(session[:member_id]) if session[:member_id]
  end
  
  def member_signed_in?
    current_member.is_a? Member
  end
  
  def authorize(member)
      session[:member_id] = member.id if member.is_a?(Member)
  end
end
