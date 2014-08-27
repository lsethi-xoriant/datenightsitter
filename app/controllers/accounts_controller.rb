class AccountsController < ApplicationController

  def account_check
    @member = current_member
    path = case @member.type
      when 'Admin'
        admin_dashboard_path
      when 'Provider'
        provider_dashboard_provider_path
      when 'Seeker'
        seeker_dashboard_seeker_path
      else
        root_path
    end

    redirect_to path

  end

end