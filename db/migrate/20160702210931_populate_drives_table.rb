class PopulateDrivesTable < ActiveRecord::Migration
  def up
    ::Drive.create(
      uuid_path: "/dev/disk/by-uuid/95f3b0ce-b884-4853-bdd9-20ee29ece528",
      name: 'Backup Drive 1',
      mount_point:'/media/usb',
      used_space: 856381833216,
      free_space: 1946944454656,
      total_space: 2953372659712
    )
    ::Drive.create(
      uuid_path: "/dev/disk/by-uuid/a67a8332-db27-4841-a933-16146f2a58aa",
      name: 'Backup Drive 2',
      mount_point:'/media/usb',
      used_space: 856381833216,
      free_space: 1946944454656,
      total_space: 2953372659712
    )
  end
  def down
    ::Drive.destroy_all
  end
end
