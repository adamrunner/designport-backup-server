class CreateBackupTable < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.datetime :started_at
      t.datetime :completed_at
      t.string :backup_drive
      t.string :exit_code
    end
  end
end
