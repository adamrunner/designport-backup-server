require 'sinatra'
require 'sqlite3'
require 'sinatra/partial'
require 'sinatra/flash'
require 'sinatra/activerecord'
class Backup < ActiveRecord::Base
  belongs_to :drive
end

class Drive < ActiveRecord::Base
  has_many :backups

  def connected?
    if BackupServer::Status.settings.development?
      drive_name == "Backup Drive 1"
    else
      File.exists?(drive_uuid_path)
    end
  end
end

module BackupServer
  class Status < Sinatra::Base
    enable :sessions
    register Sinatra::Flash
    register Sinatra::Partial
    register Sinatra::ActiveRecordExtension
    set :partial_template_engine, :erb

    set :logfile, ENV['LOGFILE_LOCATION']

    def is_backup_mounted?
      if settings.development?
        # false
        true
      else
        mounted = `mountpoint -q /media/usb && echo 'mounted' || echo 'false'`
        mounted =~ /mounted/
      end
    end
    def connected_text(drive)
      drive.connected? ? "#{drive.drive_name} - Connected" : "#{drive.drive_name} - Not Connected"
    end

    def drive_connected_class(drive)
      drive.connected? ? "text-success" : "text-danger"
    end

    def is_backup_running?
      if settings.development?
        # false
        true
      else
        File.exists?('/tmp/designport_backup.sh.lock')
      end
    end

    get '/' do
      @drives = Drive.all
      erb :index
    end

    post '/stop_drive' do
      if settings.development?

      else
        `sudo umount /media/usb`
      end
      flash[:notice] = "Unmounted Backup Drive, safe to disconnect."
      redirect '/'
    end
  end
end
