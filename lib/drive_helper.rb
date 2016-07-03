module DriveHelper
  def last_backed_up(drive)
    if drive.backups.blank?
      return "N/A"
    elsif drive.backups.last.completed_at.nil?
      return "N/A"
    else
      drive.backups.last.completed_at.strftime('%A, %d %b %Y %l:%M %p')
    end
  end

  def last_connected(drive)
    if drive.last_connected.nil?
      return "N/A"
    else
      drive.last_connected.strftime('%A, %d %b %Y %l:%M %p')
    end
  end

  def connected_text(drive)
    drive.connected? ? "#{drive.name} - Connected" : "#{drive.name} - Not Connected"
  end

  def drive_connected_class(drive)
    drive.connected? ? "bg-success" : "bg-danger"
  end

  def used_space_bar(drive)
    if drive.used_percent.to_f < 60.0
      css_class = "progress-success"
    elsif drive.used_percent.to_f > 60.0 and drive.used_percent.to_f < 75.0
      css_class = "progress-warning"
    elsif drive.used_percent.to_f > 75.0
      css_class = "progress-danger"
    end
    "<progress class='progress #{css_class}' value='#{drive.used_percent}' max='100'></progress>"
  end
end
