module ApplicationHelper

  def flash_css_select(situation)
      flash_css = "warning"
      case situation
        when :success, :warning, :info, :danger #these are the ideal flash notices to provide for bootstrap
          flash_css =  situation
        when :notice  #control for old flash notice shoices
          flash_css = "info"
        when :alert  #control for old flash notice shoices
          flash_css = "danger"
      end
      
      return flash_css
  end

end
