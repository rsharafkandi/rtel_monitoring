#!/bin/bash
#
# This script is part of Rightel Portability Monitoring Project at Tookasoft
# April 2017
#
# Developer: Ramin Sharafkandi
# Head of Team: Hamed Shakiba

MYSQL_USERNAME="root"
MYSQL_PASSWORD=""
MYSQL_HOSTNAME="localhost"
MYSQL_SCHEMA="mnp"
MODE="positive"
DEBUG_MODE="False"
DEBUG_LOG="/tmp/zabbix_mnp_monitoring.log"
SCRIPT_NAME=$( basename $0 )

logger() {
  export TZ="Asia/Tehran"
  log_date_time=$( date +"%a %x %X" )
  echo "$log_date_time - $SCRIPT_NAME - $@" >>$DEBUG_LOG
}

export TZ="GMT"

[ $DEBUG_MODE == "True" ] && logger "script called with these arguments: $@"

while [ True ]; do

   [ -z "$1" ] && break

   case "$1" in
     "-u" | "--username" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -u/--user must be followed by username"
        [ -z "$1" ] && exit 1
        MYSQL_USERNAME=$1
        shift
        ;;
     "-p" | "--password" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -p/--password must be followed by password"
        [ -z "$1" ] && exit 1
        MYSQL_PASSWORD=$1
        shift
        ;;
     "-h" | "--hostname" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -h/--host must be followed by hostname"
        [ -z "$1" ] && exit 1
        MYSQL_HOSTNAME=$1
        shift
        ;;
     "-s" | "--schema" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -s/--schema must be followed by schema name"
        [ -z "$1" ] && exit 1
        MYSQL_SCHEMA=$1
        shift
        ;;
     "-m" | "--mode" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && echo "ERROR! -m/--mode must be followed by a mode name (ie. positive or negative)"
        [ -z "$1" ] && exit 1
        MODE=$( echo $1 | tr [:upper:] [:lower:] )
        [ "$MODE" != "positive" -a "$MODE" != "negative" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! Invalid mode: $MODE"
        [ "$MODE" != "positive" -a "$MODE" != "negative" ] && exit 1
        shift
        ;;
     "--help" )
        echo "Usage $0 [-u|--username USERNAME] [-p|--password PASSWORD] [-h|--hostname HOSTNAME] [-s|--schema SCHEMANAME] [-m|--mode positive|negative]"
        echo
        echo "   This script runs a query against mysql database to get difference between entries with status=4 of this hour"
        echo "comparing with entries with status=4 of the same hour yesterday."
        echo "   Entries with status=4 denote issued SIM cards."
        echo
        exit 0
        ;;
     * )
        [ $DEBUG_MODE == "True" ] && logger "ERROR! Invalid argument: $1"
        exit 1
        ;;
   esac

done

prev_hour=`date --date="1 hour ago" +"%H"`
today_start_date=`date --date="today" +"%Y-%m-%d ${prev_hour}:00:00"`
today_end_date=`date --date="today" +"%Y-%m-%d ${prev_hour}:59:59"`
yesterday_start_date=`date --date="yesterday" +"%Y-%m-%d ${prev_hour}:00:00"`
yesterday_end_date=`date --date="yesterday" +"%Y-%m-%d ${prev_hour}:59:59"`

[ $DEBUG_MODE == "True" ] && logger "/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA}"
[ $DEBUG_MODE == "True" ] && logger "select count(*) from mnp_requestinfolog where status = 4 and createDate between '${today_start_date}' and '${today_end_date}'"
[ $DEBUG_MODE == "True" ] && logger "select count(*) from mnp_requestinfolog where status = 4 and createDate between '${yesterday_start_date}' and '${yesterday_end_date}'"

result=`
/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA} 2>&1 << EOF1:
select
( select count(*) from mnp_requestinfolog where status = 4 and createDate between '${today_start_date}' and '${today_end_date}' ) -
( select count(*) from mnp_requestinfolog where status = 4 and createDate between '${yesterday_start_date}' and '${yesterday_end_date}' );
EOF1:
`

[ $DEBUG_MODE == "True" ] && logger "result is $result"

if [ "$MODE" == "positive" ]; then
  if [ "$result" -ge 0 ]; then
    echo "$result"
  else
    echo "0"
  fi

elif [ "$MODE" == "negative" ]; then
  if [ "$result" -le 0 ]; then
    let p_result=result*-1
    echo "$p_result"
  else
    echo "0"
  fi

fi
