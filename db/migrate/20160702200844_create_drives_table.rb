class CreateDrivesTable < ActiveRecord::Migration
  def change
    create_table :drives do |t|
      t.datetime :last_connected
      t.string :drive_uuid_path
      t.string :drive_name
      t.timestamps
    end
  end
end
