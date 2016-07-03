class PopulateDrivesTable < ActiveRecord::Migration
  def up
    ::Drive.create(
      uuid_path: "/dev/disk/by-uuid/95f3b0ce-b884-4853-bdd9-20ee29ece528",
      name: 'Backup Drive 1',
      mount_point:'/media/usb',
      used_space: 2884152988,
      free_space: 1901312944,
      total_space: 2884152988      
    )
    ::Drive.create(
      uuid_path: "/dev/disk/by-uuid/a67a8332-db27-4841-a933-16146f2a58aa",
      name: 'Backup Drive 2',
      mount_point:'/media/usb',
      used_space: 2884152988,
      free_space: 1901312944,
      total_space: 2884152988
    )
  end
  def down
    ::Drive.destroy_all
  end
end
