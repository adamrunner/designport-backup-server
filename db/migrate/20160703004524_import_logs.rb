class ImportLogs < ActiveRecord::Migration
  include ::LogParser
  def up
    files = Dir.glob("/tmp/designport_backup.sh*")
    files.each do |file|
      entries = File.read(file).split("\n")
      entries.each do |entry|
        parse_log_entry(entry)
      end
    end
  end

  def down

  end
end
