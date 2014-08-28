module ApplicationHelper
  include  LinkHelper::NavLink

  def flash_class(level)
      logger.debug "#{level.to_s}"
      case level
          when "success" then "alert-success"
          when "notice", "info" then "alert-info"
          when "warning" then "alert-warning"
          when "danger", "alert", "error" then "alert-danger"
          else "alert-none"
      end
  end 

end