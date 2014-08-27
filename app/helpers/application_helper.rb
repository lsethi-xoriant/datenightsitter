module ApplicationHelper

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

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'hidden' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path, :class => 'glyphicon glyphicon-off'
    end
  end

end
