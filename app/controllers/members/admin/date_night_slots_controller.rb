module Members
  module Admin
    class DateNightSlotsController < AdminsController
  
      def new
        @date_night_slot = DateNightSlot.new
      end

      def create
        @date_night_slot = DateNightSlot.create(dns_params)
        
        unless @date_night_slot.errors.any?
          redirect_to(admin_date_night_slots_path,
                      :flash => { :success => "Date Night Slot updated" })
        else
          render :new
        end
      end

      def update
        @date_night_slot = DateNightSlot.find(params[:id])
        
        if @date_night_slot.update(dns_params)
          redirect_to(admin_date_night_slots_path,
                      :flash => { :success => "Date Night Slot updated" })
        else
          render :edit
        end
      end

      def edit
        @date_night_slot = DateNightSlot.find(params[:id])
      end

      def destroy
        if DateNightSlot.find(params[:id]).destroy
          redirect_to(admin_date_night_slots_path,
                      :flash => { :success => "Date Night #{params[:id]} deleted" })
        else
          redirect_to(admin_date_night_slots_path,
                      :flash => { :alert => "Error: unable to delete Date Night #{params[:id]}" })
        end
      end

      def index
        if params[:available_on]
          @date_night_slots = DateNightSlot.where(:available_on => params[:available_on]).order(:available_on => :desc).includes(:date_night_sittings).paginate(:per_page => 5, :page => params[:page])
          #code
        else
          @date_night_slots = DateNightSlot.all.order(:available_on => :desc).includes(:date_night_sittings).paginate(:per_page => 5, :page => params[:page])
        end
      end

      private

      def dns_params
        params.require(:date_night_slot).permit(:available_on, :starting_at, :guaranteed_openings)
      end
    end
  end
end