require 'sinatra'
require 'sqlite3'
require 'sinatra/partial'
require 'sinatra/flash'
require 'sinatra/activerecord'
class Backup < ActiveRecord::Base

end

module BackupServer
  class Status < Sinatra::Base
    enable :sessions
    register Sinatra::Flash
    register Sinatra::Partial
    register Sinatra::ActiveRecordExtension
    set :partial_template_engine, :erb

    #TODO: Make this dependent on environment
    set :logfile, ENV['LOGFILE_LOCATION']
    # set :logfile, '/var/log/designport_backup.sh.log'

    set :backup_drive_1, "/dev/disk/by-uuid/95f3b0ce-b884-4853-bdd9-20ee29ece528"

    set :backup_drive_2, "/dev/disk/by-uuid/a67a8332-db27-4841-a933-16146f2a58aa"

    def is_backup_mounted?
      if settings.development?
        # false
        true
      else
        mounted = `mountpoint -q /media/usb && echo 'mounted' || echo 'false'`
        mounted =~ /mounted/
      end
    end

    def connected_drives
      return [
        { drive: "Backup Drive 1", connected:Dir.exists?(settings.backup_drive_1)},
        { drive: "Backup Drive 2", connected:Dir.exists?(settings.backup_drive_2) }
      ]
    end

    def is_drive_connected?(drive)
      drive[:connected]
    end

    def drive_connected?(drive)
      connected = drive[:connected] ? "Connected" : "Not Connected"
      "#{drive[:drive]} - #{connected}"
    end

    def drive_connected_class(drive)
      drive[:connected] ? "text-success" : "text-danger"
    end

    def is_backup_running?(drive)
      #TODO: this isn't drive dependent in prod
      if settings.development?
        drive[:backup_running]
      else
        File.exists?('/tmp/designport_backup.sh.lock')
      end
    end

    def tail_logfile
      f = File.open(settings.logfile)
      begin
        f.seek(-8192, IO::SEEK_END)
      rescue Errno::EINVAL => e
        f.seek(0)
      end
      f.readlines.reverse.join
    end

    get '/' do
      @backup_drive     = is_backup_mounted?
      @log_file         = tail_logfile
      @connected_drives = connected_drives
      erb :index
    end

    get '/log' do
      tail_logfile
    end

    post '/stop_drive' do
      if settings.development?

      else
        `sudo umount /media/usb`
      end
      flash[:notice] = "Unmounting backup drive"
      redirect '/'
    end
  end
end
