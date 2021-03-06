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
WEB_SERVICE_NAME=""
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
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -h/--host must be followed by hostname"
        [ -z "$1" ] && exit 1
        MYSQL_SCHEMA=$1
        shift
        ;;
     "-w" | "--webservice" )
        shift
        [ -z "$1" ] && [ $DEBUG_MODE == "True" ] && logger "ERROR! -w/--webservice must be followed by a web service name"
        [ -z "$1" ] && exit 1
        WEB_SERVICE_NAME=$( echo "$1" | tr [:upper:] [:lower:] )
        shift
        ;;
     "--help" )
        echo "Usage $0 [-u|--username USERNAME] [-p|--password PASSWORD] [-h|--hostname HOSTNAME] [-s|--schema SCHEMANAME]"
        echo "         -w|--webservice SERVICENAME"
        echo
        echo "   This script runs a query against mysql database to get fail count of call of the webservice whose name is passed to script"
        echo "during last 30 minutes."
        echo
        exit 0
        ;;
     * )
        [ $DEBUG_MODE == "True" ] && logger "ERROR! Invalid argument: $1"
        exit 1
        ;;
   esac

done

if [ -z "$WEB_SERVICE_NAME" ]; then
  [ $DEBUG_MODE == "True" ] && logger "ERROR: No web-service name was passed to script"
  exit 1
fi

start_date=`date --date="-30 minutes" +"%Y-%m-%d %H:%M:%S"`
end_date=`date +"%Y-%m-%d %H:%M:%S"`

[ $DEBUG_MODE == "True" ] && logger "/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA}"
[ $DEBUG_MODE == "True" ] && logger "select count(*) from mnp_webservicelog where status = 0 and LOWER(webServiceName) = '${WEB_SERVICE_NAME}' and requestDate between '${start_date}' and '${end_date}'"

result=`
/usr/bin/mysql -sN -u ${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} -h ${MYSQL_HOSTNAME} ${MYSQL_SCHEMA} 2>&1 << EOF1:
select count(*) from mnp_webservicelog where status = 0 and LOWER(webServiceName) = '${WEB_SERVICE_NAME}' and requestDate between '${start_date}' and '${end_date}';
EOF1:
`

[ $DEBUG_MODE == "True" ] && logger "result is $result"
echo "$result"
