module Members
  module Admin
    class AdminsController < ApplicationController
      before_action :require_admin_role
      layout 'admin'

      def index
        @date_night_slots = DateNightSlot.filter_value(params.slice(:available_on)).def_paginate(params[:page])
      end
    end
  end
end