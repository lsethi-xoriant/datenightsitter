class Admin::SittingsController < Admin::AdminController
  respond_to :html, :js
  

  def create
    @sitting = Sitting.create(sitting_params)

    
    set_date_night_sittings(@sitting.date_night_slot.id)

    respond_with( @sitting) do |format|
      format.js { render "refresh"}
    end
  end
  
  def update
    @sitting = Sitting.find(params[:id])
    
    @sitting.update(sitting_params)
    
    set_date_night_sittings(@sitting.date_night_slot.id)

    respond_with( @sitting) do |format|
      format.js { render }
    end    
  end
  
  def fire_status_event
    @sitting = Sitting.find(params[:id])
    @sitting.fire_events(params[:fire_status_event])
    
    set_date_night_sittings(@sitting.date_night_slot.id)

    respond_with( @sitting) do |format|
      format.js { render "refresh"}
    end    
  end
  
  def destroy
    @sitting = Sitting.find(params[:id])

    set_date_night_sittings(@sitting.date_night_slot.id)

    @sitting.destroy
    
    
    respond_with( @sitting) do |format|
      format.js { render }
    end    
  end
  
  def date_night_sittings
    
    set_date_night_sittings(params[:slot_id])
    
  end

 
  private
  
  def sitting_params
    params.require(:sitting).permit(:provider_id, :date_night_slot_id, :type, :starting_at, :ending_at)
  end
  
  def set_date_night_sittings(slot_id)
    @available_slots = DateNightSlot.where("available_on >= ?", Date.today).order(:available_on => :asc)
    @slot = DateNightSlot.includes(:date_night_sittings).find(slot_id) unless slot_id.nil?
    @slot ||= DateNightSlot.last   #if slot is null, grab the last one
    
    @sittings = @slot.date_night_sittings
    
    if @sittings.count == 0
      @providers = Provider.all
    else
      @providers = Provider.where("id NOT IN (?)", (  ) ) 
    end

  end
end