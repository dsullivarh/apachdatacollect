#!/bin/bash

#should always exit with undefined variable
set -o nounset

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Need to provide a second timeout, $# provided"

#running with cron starting 6am est and with SECOND_TIMEOUT 61200 (17hours * 3600)
#for collecting data on apache load balancers and the apache mod_jk (reverse proxies)
SECOND_TIMEOUT=${1}

LOGDIR="/var/tmp/appdataredhat"
mkdir -p /var/tmp/appdataredhat > /dev/null 2>&1

rm -rf ${LOGDIR}/*

counter=0

DATE=$(date "+%Y%m%d_%H%M%S")
LOGPREFIX="${LOGDIR}/${DATE}_$(hostname)"

echo "#datetime@@file_usage@@apache_lsof_file_count@@parent_apache_process_rss@@avg_child_rss_kb@@apache_ps_thread_count@@apache_load" > ${LOGPREFIX}_apachedata.log 

while true
do

if [ ${counter} -eq ${SECOND_TIMEOUT} ]
then
  echo "We reached out timeout exiting"
  exit 1
fi

DATE=$(date "+%Y%m%d_%H%M%S")

echo "collecting apache data for $(hostname) at ${DATE}"
fileusage="$(sysctl -a | grep file-nr)"
lsof_count="$(lsof -u apache | wc -l)"
parent_apache_process_rss="$(ps -ylC httpd --sort:rss | awk '$2==0 { print $8 }')"
avg_child_rss_kb="$(ps --no-headers -ylC httpd --sort:rss | awk '$2!=0 {sum += $8} END { printf "%.0f\n", sum/NR }')"
ps_thread_count="$(ps H -C httpd | wc -l )"
apacheload="$(curl -s http://127.0.0.1/server-status | grep 'requests\/sec')"

echo "${DATE}@@${fileusage}@@${lsof_count}@@${parent_apache_process_rss}@@${avg_child_rss_kb}@@${ps_thread_count}@@${apacheload}" >> ${LOGPREFIX}_apachedata.log

counter=$((counter+30))

sleep 30

done

#TODO mail the file to someone because tomorrow we are going to remove it
#echo "give me data" | mail -s "testing" dsulliva@redhat.com -A /var/tmp/appdataredhat/${LOGPREFIX}_apachedata.log
