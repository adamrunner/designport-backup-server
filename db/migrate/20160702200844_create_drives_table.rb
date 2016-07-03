class CreateDrivesTable < ActiveRecord::Migration
  def change
    create_table :drives do |t|
      t.datetime :last_connected
      t.string :uuid_path
      t.string :name
      t.string :mount_point, default: '/media/usb'
      t.integer :total_space
      t.integer :free_space
      t.integer :used_space
      t.decimal :used_percent
      t.timestamps
    end
  end
end
