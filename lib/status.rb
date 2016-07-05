require 'sinatra'
require 'sqlite3'
require 'sinatra/partial'
require 'sinatra/flash'
require 'sinatra/activerecord'
require 'sinatra-websocket'
require_relative 'log_parser'
require_relative 'disk_space'
require_relative 'drive'
require_relative 'drive_helper'
require_relative 'backup_helper'
class Backup < ActiveRecord::Base
  belongs_to :drive
end


module BackupServer
  class Status < Sinatra::Base
    enable :sessions
    register Sinatra::Flash
    register Sinatra::Partial
    register Sinatra::ActiveRecordExtension
    set :partial_template_engine, :erb
    set :server, 'thin'
    set :sockets, []

    set :logfile, ENV['LOGFILE_LOCATION']
    include ::DriveHelper
    include ::BackupHelper
    def is_backup_running?
      File.exists?('/tmp/designport_backup.sh.lock')
    end

    def backup_command
      if settings.development?
        "touch /tmp/designport_backup.sh.lock && sleep 30 && rm /tmp/designport_backup.sh.lock"
      else
        "sudo /usr/local/bin/designport_backup.sh"
      end
    end

    def find_backup(options)
      automated = options[:automated] == 'true'
      @backup = Drive.connected.backups.where(automated: automated, date_string: options[:date_string]).first
      if @backup.nil?
        @backup = Drive.connected.backups.create(automated: automated, date_string: options[:date_string])
      end
    end

    ### ROUTES
    get '/' do
      if request.websocket?
        request.websocket do |ws|
          ws.onopen do
            settings.sockets << ws
          end
          ws.onclose do
            settings.sockets.delete(ws)
          end
        end
      else
        @drives = Drive.all
        @backups = Backup.order(:started_at).reverse
        erb :index
      end
    end

    get '/message' do
      EM.next_tick { settings.sockets.each{|s| s.send("RANDOM TEXT #{DateTime.now.to_s}") } }
    end

    post '/backup/create' do

      @connected_drive = Drive.connected
      if @connected_drive.nil?
        flash[:error] = "Cannot start a backup, no backup drives are connected!"
      else
        pid = Process.spawn(backup_command)
        Process.detach(pid)
        flash[:notice] = "Starting a manual backup on #{@connected_drive.name}"
      end
      redirect '/'
    end

    post '/backup/:date_string/start' do |date_string|
      find_backup({date_string: date_string, automated: params[:automated]})
      @backup.started_at = DateTime.now
      @backup.save!
    end

    post '/backup/:date_string/complete' do |date_string|
      find_backup({date_string: date_string, automated: params[:automated]})
      @backup.exit_code    = params[:exit_code]
      @backup.completed_at = DateTime.now
      @backup.save!
    end

    post '/drive/:id/connected' do |id|
      drive = Drive.find(id)
      drive.last_connected = DateTime.now
      drive.save!
    end

    post '/drive/:id/mount' do |id|
      drive = Drive.find(id)
      if drive.mount!
        EM.next_tick { settings.sockets.each{|s| s.send({drive:drive.id, status:'mounted'}.to_json) } }
        flash[:notice] = "Mounted #{drive.name}, updated drive information."
        redirect '/'
      end
    end

    post '/drive/:id/unmount' do |id|
      drive = Drive.find(id)
      if drive.unmount!
        EM.next_tick { settings.sockets.each{|s| s.send({drive:drive.id, status:'unmounted'}.to_json) } }
        flash[:notice] = "Unmounted #{drive.name}, safe to disconnect."
        redirect '/'
      end
    end
  end
end
