#!/bin/bash
ARCHIVE="backup local data and remote network share"
MONITOR_HOST="monitor local and remote system resources"
MONITOR_NETWORK="monitor the uptime of network devices"
VIEW_LOGFILES="view log files"

echo "select the operation ************"
echo "  1)$ARCHIVE"
echo "  2)$MONITOR_HOST"
echo "  3)$MONITOR_NETWORK"
echo "  4)$VIEW_LOGFILES" 



function collect_info_on_remote() {
    echo "Please input remote host ip:"
    read HOST_IP
    echo "Please input login username:"
    read USER_NAME
    echo "Please input login password:"
    read PASS_WORD
    echo "Collecting information from remote host: $HOST_IP"
    PROMPT=$@
    COLLECTED_INFO=$(expect -c "
    spawn ssh $USER_NAME@$HOST_IP
    expect \"password:\"
    send \"$PASS_WORD\r\"
    expect \"\\\\$\"
    send \"top -bn1 | grep 'Cpu(s)'\r\"
    expect \"\\\\$\"
    send \"awk '/MemFree/' /proc/meminfo\r\"
    expect \"\\\\$\"
    send \"df -h --total | grep 'total'\r\"
    expect \"\\\\$\"
    send \"logout\"
    ")

    echo "$COLLECTED_INFO" 
    CPU_LINE=$(echo "$COLLECTED_INFO" | grep "Cpu(s)")
    CPU_USAGE=$(echo $CPU_LINE |  sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    echo $CPU_USAGE

    MEM_USAGE_LINE=$(echo "$COLLECTED_INFO" | grep 'MemFree:')
    MEM_USAGE=$(echo $MEM_USAGE_LINE | sed -e 's/[^0-9]//g')
    echo $MEM_USAGE

    AVAILABLE_DISK_LINE=$(echo "$COLLECTED_INFO" | grep "total" | awk '{split($0,a," "); print a[4]}')
    AVAILABLE_DISK=$(echo $AVAILABLE_DISK_LINE |  awk '{split($0,a," "); print a[2]}')
    echo $AVAILABLE_DISK
    DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
    echo "$DATE_WITH_TIME REMOTE HOST: $HOST_IP cpu usage: $CPU_USAGE, mem usage: $MEM_USAGE available disk: $AVAILABLE_DISK." >> SysMonitor.log
}

function collect_info_on_local() {
    echo "Collecting information from local host."
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    echo $CPU_USAGE
    MEM_USAGE=$(awk '/MemFree/ { printf "%.3fG\n", $2/1024/1024 }' /proc/meminfo)
    echo "${MEM_USAGE}"
    AVAILABLE_DISK=$(df -h --total | grep "total" | awk '{split($0,a," "); print a[4]}')
    echo $AVAILABLE_DISK
    DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
    echo "$DATE_WITH_TIME LOCAL HOST cpu usage: $CPU_USAGE, mem usage: $MEM_USAGE available disk: $AVAILABLE_DISK." >> SysMonitor.log
}

function collect_info() {
    echo "select the operation: local or remote ************"
    echo "  1) local"
    echo "  2) remote"
    
    read LOCAL_OR_REMOTE
    if [ $LOCAL_OR_REMOTE -eq 1 ]; then
        collect_info_on_local
    else
        collect_info_on_remote
    fi

}

function archive() {
    echo "Please input the source file directory that you want to backup:"
    read SRC
    echo "Please input the remote host ip:"
    read HOST_IP
    echo "Please input the remote host login username:"
    read USER_NAME
    echo "Please input the remote host login password:"
    read PASS
    echo "Please input the remote file directory that you want to backup to:"
    read DST
    echo "Please input the execution delay time(s):"
    read TIME
    CMD=$@
    timeout $TIME expect -c "
        spawn scp $SRC $USER_NAME@$HOST_IP:$DST
        expect \"password:\"
        send \"$PASS\r\"
        expect \"\\\\$\"
        send \"$CMD\r\"
        expect \"\\\\$\""
    DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
    echo "$DATE_WITH_TIME backup dir $SRC to $HOST_IP $DST" >> Archive.log

}

function monitor() {
    echo "Please input the network device ip:"
    read HOST
    echo "Please input the network device login username:"
    read USER
    echo "Please input the network device login password:"
    read PASS
    echo "Collecting information from network device: $HOST"

CMD=$@

COLLECTED_INFO=$(expect -c "
spawn ssh $USER@$HOST
expect \"password:\"
send \"$PASS\r\"
expect \"\\\\$\"
    send \"uptime -p\r\"
    expect \"\\\\$\"
send \"logout\"
")
UPTIME=$(echo "$COLLECTED_INFO" | grep "^up")
DATE_WITH_TIME=`date "+%Y%m%d-%H%M%S"`
    echo "$DATE_WITH_TIME $HOST $UPTIME." >> NetMonitor.log
}

function view() {
  echo "current log files"
  echo "select files to view"
  echo "  1)Archive.log"
  echo "  2)SysMonitor.log"
  echo "  3)NetMonitor.log"
  read FILE
  echo $FILE
  case $FILE in 
    1) 
      echo "read Archive.log"
      ;;
    2) echo "read SysMonitor.log"
      while IFS= read -r line; do
        echo "Text read from file: $line"
      done < SysMonitor.log
      ;;
    3) 
      echo "read NetMonitor.log"
      while IFS= read -r line; do
        echo "Text read from file: $line"
      done < NetMonitor.log
      ;;
  esac
}

read n
case $n in
  1) 
    echo "You chose to $ARCHIVE"
    archive
    ;;
  2) 
    echo "You chose to $MONITOR_HOST"
    collect_info
    ;;
  3) echo "You chose to $MONITOR_NETWORK"
    monitor
    ;;
  4) echo "You chose to $VIEW_LOGFILES"
    view
    ;;
  *) echo "invalid option";;
esac




