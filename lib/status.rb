module BackupServer
  class Status < Sinatra::Base


    set :logfile, '/var/log/designport_backup.sh.log'

    def is_backup_mounted?
      mounted = `mountpoint -q /media/usb && echo 'mounted' || echo 'false'`
      mounted =~ /mounted/
    end

    def is_backup_running?
      #TODO: determine if backup is currently running - lock file present etc.
    end

    def tail_logfile
      IO.readlines(settings.logfile).reverse.join
    end

    get '/' do
      @backup_drive = is_backup_mounted?
      @log_file = tail_logfile
      erb :index
    end

    post '/stop_drive' do
      `sudo umount /media/usb`
      redirect '/'
    end
  end
end
