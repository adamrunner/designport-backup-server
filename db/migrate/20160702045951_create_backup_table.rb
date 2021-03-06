class CreateBackupTable < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.string   :date_string
      t.datetime :started_at
      t.datetime :completed_at
      t.string   :exit_code
      t.integer  :drive_id
      t.boolean  :automated, default: true
      t.timestamps
    end
  end
end
