#!/bin/bash
#
# This script is part of Rightel Portability Monitoring Project at Tookasoft
# April 2017
#
# Developer: Ramin Sharafkandi
# Head of Team: Hamed Shakiba

LIBRARY_PATH="lib"
FTP_IP_ADDRESS="172.20.7.4"
FTP_USERNAME=xxx
FTP_PASSWORD=yyy
DEBUG_MODE="False"
DEBUG_LOG="/tmp/zabbix_mnp_monitoring.log"
DEST_DIR="/tmp"

logger() {
  export TZ="Asia/Tehran"
  log_date_time=$( date +"%a %x %X" )
  echo "$log_date_time - $SCRIPT_NAME - $@" >>$DEBUG_LOG
}

export TZ="GMT"

[ $DEBUG_MODE == "True" ] && logger "Script called with these arguments: $@"

if [ ! -z "$1" ]; then
   today_date=$1
else
   today_date=$(date +%Y%m%d)
fi

today_date_sh=$(${LIBRARY_PATH}/greg2jalali.sh $today_date)

[ ${#today_date_sh} -ne 8 ] && [ $DEBUG_MODE == "True" ] logger "ERROR! Invalid date: $today_date_sh"
[ ${#today_date_sh} -ne 8 ] && [ $DEBUG_MODE == "True" ] && exit 1

mnp_report_file=$(echo MNP${today_date_sh:2:7}-*)

[ $DEBUG_MODE == "True" ] && logger "Trying to download mnp_report_file.xlsx from ${FTP_IP_ADDRESS} to ${DEST_DIR} ..."

ftp -n -i -p >/dev/null 2>&1 <<EOF1
open ${FTP_IP_ADDRESS}
lcd ${DEST_DIR}
user ${FTP_USERNAME} ${FTP_PASSWORD}
cd request
bin
mget ${mnp_report_file}\*
EOF1

latest_report_file=$(ls -1tr ${DEST_DIR}/${mnp_report_file}* | tail -n 1)
[ $DEBUG_MODE == "True" ] && logger "Latest downloaded report filename is : $latest_report_file"

row_count=$(java -cp ${LIBRARY_PATH}/examineMNPFile-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.tooka.rightel.MNPMonitoring.ApachePOIExcelParserRunnable -f ${latest_report_file} -c rowcount)

[ $DEBUG_MODE == "True" ] && logger "Row count of ${latest_report_file} is $row_count"

echo ${row_count}
