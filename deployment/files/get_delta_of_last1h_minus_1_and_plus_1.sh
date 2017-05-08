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
     "--help" )
        echo "Usage $0 [-u|--username USERNAME] [-p|--password PASSWORD] [-h|--hostname HOSTNAME] [-s|--schema SCHEMANAME]"
        echo
        echo "   This script runs a query against mysql database to get difference between entries with status=-1 (sms sent) and"
        echo "entries with status=1 (registered requests) during the last hour."
        echo
        exit 0
        ;;
     * )
        [ $DEBUG_MODE == "True" ] && "ERROR! Invalid argument: $1"
        exit 1
        ;;
   esac

done

start_date=`date --date="1 hour ago" +"%Y-%m-%d %H:%M:%S"`
end_date=`date +"%Y-%m-%d %H:%M:%S"`

[ $DEBUG_MODE == "True" ] && logger "/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA}"
[ $DEBUG_MODE == "True" ] && logger "select count(*) from mnp_requestinfolog where status = -1 and createDate between '${start_date}' and '${end_date}'"
[ $DEBUG_MODE == "True" ] && logger "select count(*) from mnp_requestinfolog where status = 1 and createDate between '${start_date}' and '${end_date}'"

result=`
/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA} 2>&1 << EOF1:
SELECT ABS(
  (select count(*) from mnp_requestinfolog where status = -1 and createDate between '${start_date}' and '${end_date}') -
  (select count(*) from mnp_requestinfolog where status = 1 and createDate between '${start_date}' and '${end_date}') );
EOF1:
`

[ $DEBUG_MODE == "True" ] && logger "result is $result"

echo "$result"
