#!/bin/bash

readonly PROGNAME=$(basename "$0")
readonly LOCKFILE_DIR=/tmp
readonly LOCK_FD=200
readonly SOURCE='/media/data/'
readonly DESTINATION='/media/usb'
readonly LOG_FILE="/var/log/$PROGNAME.log"
readonly EXCLUDE_FILE='/etc/rsync-exclude'
readonly MOUNT_POINT='/media/usb'
readonly BACKUP_DRIVE_1='/dev/disk/by-uuid/95f3b0ce-b884-4853-bdd9-20ee29ece528'
readonly BACKUP_DRIVE_2='/dev/disk/by-uuid/a67a8332-db27-4841-a933-16146f2a58aa'
readonly DATE_STRING=`date +%Y%m%d`
LOCK_FILE=''
lock() {
    local prefix=$1
    local fd=${2:-$LOCK_FD}
    local lock_file=$LOCKFILE_DIR/$prefix.lock
    LOCK_FILE="$lock_file"
    # create lock file
    eval "exec $fd>$lock_file"

    # acquire the lock
    flock -n $fd \
        && return 0 \
        || return 1
}

eexit() {
    local error_str="$@"
    echo $error_str >> $LOG_FILE
    echo $error_str
    exit 1
}

determineDriveToMount(){
  if [ -b "$BACKUP_DRIVE_1" ];
  then
   echo `date +%Y/%m/%d' '%T` "Found Backup Drive 1" >> $LOG_FILE
   curl -XPOST http://localhost/drive/1/connected
   DEVICE="$BACKUP_DRIVE_1"
  fi
  if [ -b "$BACKUP_DRIVE_2" ];
  then
    echo `date +%Y/%m/%d' '%T` "Found Backup Drive 2" >> $LOG_FILE
    curl -XPOST http://localhost/drive/2/connected
    DEVICE="$BACKUP_DRIVE_2"
  fi
}

mountUsbDrive() {
  if mountpoint -q $MOUNT_POINT
  then
     echo `date +%Y/%m/%d' '%T` "Backup drive already mounted" >> $LOG_FILE
  else
    determineDriveToMount
    mount $DEVICE $MOUNT_POINT
    echo `date +%Y/%m/%d' '%T` "Mounted backup drive" >> $LOG_FILE
  fi
}

createLogFile() {
  `touch $LOG_FILE`
  echo `date +%Y/%m/%d' '%T` "Starting designPORT backup from $SOURCE to $DESTINATION" >> $LOG_FILE
}

runBackup() {

  curl -XPOST "http://localhost/backup/$DATE_STRING/start?automated=$AUTOMATED"

  rsync -a  --exclude-from=$EXCLUDE_FILE $SOURCE $DESTINATION
  EXIT_CODE=$?

  echo `date +%Y/%m/%d' '%T` 'Finishing designPORT backup - Exit Code ' $EXIT_CODE >> $LOG_FILE

  curl -XPOST "http://localhost/backup/$DATE_STRING/complete?automated=$AUTOMATED&exit_code=$EXIT_CODE"

  umount $MOUNT_POINT
  echo `date +%Y/%m/%d' '%T` 'Unmounted backup drive' >> $LOG_FILE
  rm $LOCK_FILE
  echo `date +%Y/%m/%d' '%T` 'Removed Lock File' >> $LOG_FILE
}

checkIfRoot() {
  if [[ $EUID -ne 0 ]]; then
    eexit "You must run this script as root"
 fi
}

checkIfDriveMounted() {
  if mountpoint -q $MOUNT_POINT
  then
    echo `date +%Y/%m/%d' '%T` 'USB Drive mounted OK' >> $LOG_FILE
  else
    eexit "ERROR $MOUNT_POINT is not a valid mount point"
  fi
}
main() {
  checkIfRoot
  lock $PROGNAME \
      || eexit "`date +%Y/%m/%d' '%T` Only one instance of $PROGNAME can run at one time."

    mountUsbDrive
    checkIfDriveMounted
    createLogFile
    runBackup
}

main
