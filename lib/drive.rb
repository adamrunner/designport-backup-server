class Drive < ActiveRecord::Base
  has_many :backups

  before_save :update_drive_stats

  def mounted?
    if BackupServer::Status.settings.development?
      @mounted
    else
      mounted = `mountpoint -q #{mount_point} && echo 'mounted' || echo 'false'`
      @mounted = mounted =~ /mounted/
    end
  end

  def mount!
    if BackupServer::Status.settings.development?
      @mounted = true
    else
      `sudo mount #{uuid_path} #{mount_point}`
      save
    end
  end

  def unmount!
    if BackupServer::Status.settings.development?
      @mounted = false
    else
      `sudo umount #{mount_point}`
    end
  end

  def connected?
    return false if new_record?
    if BackupServer::Status.settings.development?
      if name == "Backup Drive 1"
        update_column(:last_connected, DateTime.now)
        return true
      end
    elsif File.exists?(uuid_path)
      update_column(:last_connected, DateTime.now)
      return true
    end
    return false
  end

  def free_space
    if connected? and mounted?
      update_drive_stats
    end
    read_attribute(:free_space)
  end

  def used_space
    if connected? and mounted?
      update_drive_stats
    end
    read_attribute(:used_space)
  end

  def total_space
    if connected? and mounted?
      update_drive_stats
    end
    read_attribute(:total_space)
  end

  def mount_point
    if BackupServer::Status.settings.development?
      return "/"
    else
      read_attribute(:mount_point)
    end
  end

  protected
  def update_drive_stats
    if connected? and mounted?
      self.free_space   = DiskSpace::Free.bytes(mount_point)
      self.used_space   = DiskSpace::Used.bytes(mount_point)
      self.total_space  = DiskSpace::Total.bytes(mount_point)
      self.used_percent = DiskSpace::Used.percent(mount_point)
    end
  end
end
