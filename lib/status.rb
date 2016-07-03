require 'sinatra'
require 'sqlite3'
require 'sinatra/partial'
require 'sinatra/flash'
require 'sinatra/activerecord'
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

    set :logfile, ENV['LOGFILE_LOCATION']
    include ::DriveHelper
    include ::BackupHelper
    def is_backup_running?
      if settings.development?
        false
        # true
      else
        File.exists?('/tmp/designport_backup.sh.lock')
      end
    end

    def find_automated_backup(date_string)
      @backup = Backup.where(automated: true, date_string: date_string).first
      if @backup.nil?
        @backup = Backup.create(automated: true, date_string: date_string)
      end
    end

    ### ROUTES
    get '/' do
      @drives = Drive.all
      @backups = Backup.order(:completed_at).reverse
      erb :index
    end

    post '/backup/create' do

      @connected_drive = Drive.connected
      if @connected_drive.nil?
        flash[:error] = "Cannot start a backup, no backup drives are connected!"
      else
        #TODO: start a new backup in a different thread here
        date_string = Date.today.to_s.gsub("-", "")
        @backup = Backup.create(date_string: date_string, automated: false, drive: @connected_drive)
        flash[:notice] = "Starting a manual backup on #{@connected_drive.name}"
      end
      redirect '/'
    end

    post '/backup/:date_string/start' do |date_string|
      find_automated_backup(date_string)
      @backup.started_at = DateTime.now
      @backup.save!
    end

    post '/backup/:date_string/complete' do |date_string|
      find_automated_backup(date_string)
      @backup.exit_code = "0"
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
        flash[:notice] = "Mounted #{drive.name}, updated drive information."
        redirect '/'
      end
    end

    post '/drive/:id/unmount' do |id|
      drive = Drive.find(id)
      if drive.unmount!
        flash[:notice] = "Unmounted #{drive.name}, safe to disconnect."
        redirect '/'
      end
    end
  end
end
