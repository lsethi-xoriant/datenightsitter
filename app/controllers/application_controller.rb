class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #require authentication on most pages
  before_action :require_authentication

  helper_method :current_member,
                :current_sittercity_account,
                :authenticate_member,
                :require_authentication,
                :member_authenticated?,
                :require_admin_role,
                :member_admin?
  private
  
  def current_member
    @current_member ||= session[:sittercity_account].member if session[:sittercity_account]
  end
  
  def current_sittercity_account
    session[:sittercity_account]
  end
  
  #authenticate 
  def authenticate_member(email, password, save = false)
    logger.debug "authentication called for #{email}"

    #authenticate user given params
    s = Sittercity::API::Client.new( Rails.application.secrets.sittercity_api_endpoint )
    s.register(:application_type => Rails.application.secrets.sittercity_api_application_type ,
               :name => Rails.application.secrets.sittercity_api_application_name )
    s.authenticate!(:email => email, :password => password)

    #create and store SittercityAccount if member authenticates
    session[:sittercity_account] = SittercityAccount.new(s) if s.token
    
  rescue Sittercity::API::Client::Unauthorized => e
        logger.error "Unable to login user - User not authorized"
  end

  def member_authenticated?
    result = false
    acct = session[:sittercity_account]
    if acct.is_a?(SittercityAccount)
      if acct.has_expired?
        result = (acct.refresh_authentication == true)
      else
        result = true
      end
    end
  end
  
  def require_authentication
    unless member_authenticated?
      flash[:error] = "You must be logged in to access this section"
      redirect_to log_in_path # halts request cycle
    end
  end
  
  def member_admin?
    current_member.is_a?(Admin)
  end
  
  def require_admin_role
    unless member_admin?
      flash[:error] = "You must be an Admin to access this section"
      redirect_to log_in_path # halts request cycle
    end
  end
end
