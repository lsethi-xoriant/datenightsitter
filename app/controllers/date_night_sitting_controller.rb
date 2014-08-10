class DateNightSittingController < ApplicationController
  respond_to :html, :json
  
  def create
    @dns = DateNightSitting.create(dns_params)
    respond_with @dns, :location => nil, :status => 201
  end

  def update
    @dns = DateNightSitting.find(params[:id])
    @dns.toggle_availability if params[:date_night_sitting][:status]
    respond_with @dns
  end
  
  private

  def dns_params
    params.require(:date_night_sitting).permit(:status,
                                               :available_on,
                                               :starting_at,
                                               :ending_at,
                                               :provider_id,
                                               :seeker_id,
                                               :date_night_slot_id)
  end
  
end


