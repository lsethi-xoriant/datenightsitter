module Members
  module Admin
    class AdminsController < ApplicationController
      before_action :require_admin_role
      layout 'role_layout/admin'

      def index
        @date_night_slots = DateNightSlot.filter_value(params.slice(:available_on)).order(:available_on => :desc).includes(:date_night_sittings).paginate(:per_page => 5, :page => params[:page])
      end
    end
  end
end