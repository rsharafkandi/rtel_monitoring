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
WHEN="today"
STATUS="0"
DEBUG_MODE="False"
DEBUG_LOG="/tmp/zabbix_mnp_monitoring.log"
SCRIPT_NAME=$( basename $0 )

logger() {
  export TZ="Asia/Tehran"
  log_date_time=$( date +"%a %x %X" )
  echo "$log_date_time - $SCRIPT_NAME - $@" >>$DEBUG_LOG
}

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
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -s/--schema must be followed by schema (database) name"
        [ -z "$1" ] && exit 1
        MYSQL_SCHEMA=$1
        shift
        ;;
     "-t" | "--status" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -t/--status must be followed by a number (e.g.: -1 for sms_sent, -2 for user verified sms ..."
        [ -z "$1" ] && exit 1
        STATUS=$1
        let STATUS_PLUS_ZERO=STATUS+0
        if [ "$STATUS_PLUS_ZERO" != "$STATUS" ]; then
           [ $DEBUG_MODE == "True" ] && logger "ERROR! The passed status ($STATUS) is not a vaild integer number"
           exit 1 
        fi
        shift
        ;;
     "-w" | "--when" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -w/--when must be followed by a date expression (ie today/yesterday ..)"
        [ -z "$1" ] && exit 1
        WHEN=$( echo $1 | tr [:upper:] [:lower:] )
        [ "$WHEN" != "today" -a "$WHEN" != "yesterday" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! Invalid mode: $WHEN"
        [ "$WHEN" != "today" -a "$WHEN" != "yesterday" ] && exit 1
        shift
        ;;
     "--help" )
        echo "Usage $0 [-u|--username USERNAME] [-p|--password PASSWORD] [-h|--hostname HOSTNAME] [-s|--schema SCHEMANAME]"
        echo
        echo "   This script runs a query against mysql database to get count of entries with status=STATUS on today or on yesterday" 
        echo "depending on --when parameter (by default is today)"
        echo
        echo " Some valid statuses are:"
        echo "    -1  : SMS Sent to user"
        echo "    -2  : User verified SMS Reception"
        echo "    10  : SHAHKAR verification done"
        echo
        exit 0
        ;;
     * )
        [ $DEBUG_MODE == "True" ] && logger "ERROR! Invalid argument: $1"
        exit 1
        ;;
   esac

done

export TZ="GMT"
start_date=`date --date="$WHEN" +"%Y-%m-%d 00:0:01"`
end_date=`date --date="$WHEN" +"%Y-%m-%d 23:59:59"`

[ $DEBUG_MODE == "True" ] && logger "/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA}"
[ $DEBUG_MODE == "True" ] && logger "select count(*) from mnp_requestinfolog where status = ${STATUS} and createDate between '${start_date}' and '${end_date}'"

result=`
/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA} 2>&1 << EOF1:
select count(*) from mnp_requestinfolog where status = ${STATUS} and createDate between '${start_date}' and '${end_date}';
EOF1:
`

[ $DEBUG_MODE == "True" ] && logger "result is $result"
echo "$result"
