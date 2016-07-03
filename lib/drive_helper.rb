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
    drive.connected? ? "text-success" : "text-danger"
  end
end
