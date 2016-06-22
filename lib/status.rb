module BackupServer
  class Status < Sinatra::Base

    #TODO: Make this dependent on environment
    set :logfile, ENV['LOGFILE_LOCATION']
    # set :logfile, '/var/log/designport_backup.sh.log'

    set :backup_drive_1, "/dev/disk/by-uuid/95f3b0ce-b884-4853-bdd9-20ee29ece528"

    set :backup_drive_2, "/dev/disk/by-uuid/a67a8332-db27-4841-a933-16146f2a58aa"

    def is_backup_mounted?
      mounted = `mountpoint -q /media/usb && echo 'mounted' || echo 'false'`
      mounted =~ /mounted/
    end

    def connected_drives
      return {
        drive_1: Dir.exists?(settings.backup_drive_1),
        drive_2: Dir.exists?(settings.backup_drive_2)
      }
    end

    def is_backup_running?
      #TODO: determine if backup is currently running - lock file present etc.
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
      `sudo umount /media/usb`
      redirect '/'
    end
  end
end
