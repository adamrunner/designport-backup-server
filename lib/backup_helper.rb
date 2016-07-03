module BackupHelper
  def row_class(backup)
    if backup.exit_code != "0"
      "table-danger"
    end
  end

  def exit_code(backup)
    if backup.exit_code == "0"
      "<i class='fa fa-check text-success'></i>"
    else
      "<i class='fa fa-times text-danger'></i>"
    end
  end

  def started_at(backup)
    if backup.started_at
      backup.started_at.strftime('%A, %d %b %Y %l:%M %p')
    else
      return "N/A"
    end
  end

  def completed_at(backup)
    if backup.completed_at
      backup.completed_at.strftime('%A, %d %b %Y %l:%M %p')
    else
      return "N/A"
    end
  end

  def automated(backup)
    if backup.automated
      "<i class='fa fa-check text-success'></i>"
    else
      "<i class='fa fa-times text-danger'></i>"
    end
  end
end
