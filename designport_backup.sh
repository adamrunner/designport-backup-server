#!/bin/bash

readonly PROGNAME=$(basename "$0")
readonly LOCKFILE_DIR=/tmp
readonly LOCK_FD=200
readonly SOURCE='/media/engineering'
readonly DESTINATION='/media/usb'
readonly LOG_FILE="/var/log/$PROGNAME.log"
readonly EXCLUDE_FILE='/etc/rsync-exclude'
readonly MOUNT_POINT='/media/usb'

lock() {
    local prefix=$1
    local fd=${2:-$LOCK_FD}
    local lock_file=$LOCKFILE_DIR/$prefix.lock

    # create lock file
    eval "exec $fd>$lock_file"

    # acquier the lock
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

mountUsbDrive() {
  if mountpoint -q $MOUNT_POINT
  then
     echo `date +%Y/%m/%d' '%T` "Backup drive already mounted" >> $LOG_FILE
  else
    mount /dev/sdb1 $MOUNT_POINT
    echo `date +%Y/%m/%d' '%T` "Mounted backup drive" >> $LOG_FILE
  fi
}

createLogFile() {
  `touch $LOG_FILE`
  echo `date +%Y/%m/%d' '%T` "Starting designPORT backup from $SOURCE to $DESTINATION" >> $LOG_FILE
}

runBackup() {
  rsync -a --no-perms --exclude-from=$EXCLUDE_FILE --log-file=$LOG_FILE $SOURCE $DESTINATION

  echo `date +%Y/%m/%d' '%T` 'Finishing designPORT backup' >> $LOG_FILE
  umount $MOUNT_POINT
  echo `date +%Y/%m/%d' '%T` 'Unmounted backup drive' >> $LOG_FILE
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
  mountUsbDrive
  checkIfDriveMounted
  createLogFile
    lock $PROGNAME \
        || eexit "`date +%Y/%m/%d' '%T` Only one instance of $PROGNAME can run at one time."

    runBackup
}

main
