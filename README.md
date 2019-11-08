# apachdatacollect

Monitor apache usage during production and or testing

This monitors the following:

* system file usage
* apache open file count
* apache parent process rss
* apache child threads average size rss
* apache thread count
* apache load relative to request/sec and throughput per request

Prerequsities

* mod_status enabled

Script called apache_data_collect_high_load.sh

Arguments: 1 takese timeout count in seonds

Can be operationized via cron

e.g.

#start script 6 am it will run for 17 hrs or 61200 seconds you can adjust this as desired
crontab -e
0 6 * * * /bin/bash /root/apache_data_collect_high_load.sh 61200 > /dev/null 2>&1

Output directory is hard coded to /var/tmp/apachedatarh

The script will overwrite daily to mitigate against creating filesystem space issues.

If you have mail in enabled the script has a commented out example of how to email the data out.

Output looks as follows:

#datetime@@file_usage@@apache_lsof_file_count@@parent_apache_process_rss@@avg_child_rss_kb@@apache_ps_thread_count@@apache_load
20191108_102001@@@@770@@11960@@6427@@215@@<dt>.000308 requests/sec - 1 B/second - 5.4 kB/request</dt>
20191108_102031@@@@770@@11960@@6427@@215@@<dt>.000331 requests/sec - 1 B/second - 5.5 kB/request</dt>
