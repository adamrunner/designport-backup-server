module LogParser
  def parse_log_entry(entry)
    backup_drive_regex = /(\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}).+(Backup Drive \d)/
    completed_regex = /(\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}).+(Finishing)/
    starting_regex = /(\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}).+(Starting)/
    if backup_drive_regex.match(entry)
      date_string  = Date.parse(backup_drive_regex.match(entry)[1]).to_s.gsub("-", "")
      backup       = Backup.find_or_create_by_date_string(date_string)
      drive        = backup_drive_regex.match(entry)[2]
      backup.drive = Drive.where(name: drive).first
      backup.save!
    elsif completed_regex.match(entry)
      date_string         = Date.parse(completed_regex.match(entry)[1]).to_s.gsub("-", "")
      backup              = Backup.find_or_create_by_date_string(date_string)
      backup.completed_at = DateTime.parse(completed_regex.match(entry)[1]+ " -0700")
      backup.exit_code    = 0
      backup.save!
    elsif starting_regex.match(entry)
      date_string       = Date.parse(starting_regex.match(entry)[1]).to_s.gsub("-", "")
      backup            = Backup.find_or_create_by_date_string(date_string)
      backup.started_at = DateTime.parse(starting_regex.match(entry)[1]+ " -0700")
      backup.save!
    end
  end
end
