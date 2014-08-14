class SittercityProfile

  attr_reader :account, :attributes, :education, :badges, :qualifications, :childcare, :babysitter, :location, :links, :details

  # create a new sittercity profile.  common use would be:
  #   response = @api_client.provider_profile(sso_uuid).stringify_keys    
  #   SittercityProfile.new ( response["com.sittercity.profile:Provider"]
  #
  def initialize(profile)
    Rails.logger.debug "profile: #{profile}"
    @details = profile
    @account = @details.delete("com.sittercity.profile:Account")
    @attributes = @details.delete("com.sittercity.profile:Attributes")
    @education = @details.delete("com.sittercity.profile:Education")
    @badges = @details.delete("com.sittercity.profile:Badges")
    @qualifications = @details.delete("com.sittercity.profile:Qualifications")
    @childcare = @details.delete("com.sittercity.profile:Childcare")
    @babysitter = @childcare.delete("com.sittercity.profile:Childcare.Babysitter")
    @location = @details.delete("com.sittercity.location:Position")
    @links = @details.delete("_links")
  end

end