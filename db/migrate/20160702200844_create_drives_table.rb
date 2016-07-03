class CreateDrivesTable < ActiveRecord::Migration
  def change
    create_table :drives do |t|
      t.datetime :last_connected
      t.string :uuid_path
      t.string :name
      t.timestamps
    end
  end
end
