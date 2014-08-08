class SittercityAccount
  
  attr_reader :api_client

  def initialize(api_client)
    @api_client = api_client
    account = JSON.parse(api_client.my_account.response_body)["com.sittercity.account:Account"]
    @contact = account["com.sittercity.account:Contact"]
    @roles = account["com.sittercity.rbac:Roles"]
  end

  def sso_uuid
    @contact["sso_uuid"]
  end

  def first_name
    @contact["first_name"]
  end

  def last_name
    @contact["last_name"]
  end
  
  def email
    @contact["email"]
  end
  
  def location
    @contact["location"]
  end
  
  def mobile_phone
    @contact["mobile"]
  end
  
  def is_seeker?
    has_role("seeker")
  end
  
  def is_provider?
    has_role("provider")
  end
  
  def is_member?
    !member.nil?
  end
  
  def member
    Member.find_by_email(email)
  end
  
  def has_expired?
    authentication_expires_at < Time.now
  end
  
  def refresh_authentication
    @api_client.refresh_authentication!( @api_client.token.refresh_token )
  end
  
  def authentication_expires_at
    api_client.token.issued_at + api_client.token.expires_in
  end
  
  def provider_profile
    if is_provider?
      response = @api_client.provider_profile(sso_uuid).deep_stringify_keys    #s
      SittercityProfile.new ( response["com.sittercity.profile:Provider"]  )
    else
      nil
    end
  end
    

  private
  
  def has_role(role)
    result = false
    @roles.each do |r|
      result = true if r["com.sittercity.rbac:Role"] == "com.sittercity.empire:Role.#{role}"
    end
    result
  end
  
end