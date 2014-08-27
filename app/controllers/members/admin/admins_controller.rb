module Members
  module Admin
    class AdminsController < ApplicationController
      layout 'role_layout/admin'
      before_action :require_admin_role

      def index
        if params[:available_on]
          @date_night_slots = DateNightSlot.where(:available_on => params[:available_on]).order(:available_on => :desc).includes(:date_night_sittings).paginate(:per_page => 5, :page => params[:page])
          #code
        else
          @date_night_slots = DateNightSlot.all.order(:available_on => :desc).includes(:date_night_sittings).paginate(:per_page => 5, :page => params[:page])
        end
      end
    end
  end
end