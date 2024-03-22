#!/bin/bash

# ss_counters.sh - monitors hades counters over time
# version 0.5
# gabriele@imperva.com
# usage: ./ss_counters.sh d|w > outfile.csv &
# d = one day sampling
# w = one week sampling

interval=1 	#sampling every X minutes
rounds=10 	#default if d nor w are specified

if [ "$1" = "d" ]; then
   rounds=60*24/$interval
fi

if [ "$1" = "w" ]; then
   rounds=60*24*7/$interval
fi

#untraceable is incremental, so we have to track the difference
prev_untraceable=$(awk '/(\[\!\] SSL reuse untraceable connection \(unsupported cipher\) \(SSL\)\: )([0-9]+)(.*)/{print $9}' /opt/SecureSphere/etc/proc/hades/nzcounters)

echo 'date;time;connection;httphits;kbps;kpbsapp;overload;untraceable;cpu;ssl_rsa;ssl_dh;ssl_ecdh;streams_streams;streams_estab;sqlhits;overloadsqlhits'

for (( i=1; i <= rounds ; i++)); do

   #echo "DEBUG i=$i rounds=$(($rounds)) arg=$1" #debug variables

   connection=$(awk '/(^ +)([0-9]+)( connection\/sec)/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   httphits=$(awk '/(^ +)([0-9]+)( HTTP hits\/sec)/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   kbps=$(awk '/(^ +)([0-9]+)( Kbps  )/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   kbpsapp=$(awk '/(^ +)([0-9]+)( Kbps Application)/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   overload=$(awk '/(^ +)([0-9]+)( overload connection\/sec)/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   curr_untraceable=$(awk '/(\[\!\] SSL reuse untraceable connection \(unsupported cipher\) \(SSL\)\: )([0-9]+)(.*)/{print $9}' /opt/SecureSphere/etc/proc/hades/nzcounters)
   untraceable=$((curr_untraceable - prev_untraceable))
   prev_untraceable=$curr_untraceable
   cpu=$(awk '/(^average load: )([0-9]+)/{print $3;exit}' /opt/SecureSphere/etc/proc/hades/cpuload)
   ssl_rsa=$(awk '/(^ +)([0-9]+)( SSL RSA)/{print $1}' /opt/SecureSphere/etc/proc/hades/ssl/status)
   ssl_dh=$(awk '/(^ +)([0-9]+)( SSL DH)/{print $1}' /opt/SecureSphere/etc/proc/hades/ssl/status)
   ssl_ecdh=$(awk '/(^ +)([0-9]+)( SSL ECDH)/{print $1}' /opt/SecureSphere/etc/proc/hades/ssl/status)
   streams_streams=$(awk '/(^Total     :)( +)([0-9]+)/{print $3}' /opt/SecureSphere/etc/proc/hades/streams)
   streams_estab=$(awk '/(^Total     :)( +)([0-9]+)( +)([0-9]+)( +)([0-9]+)( +)([0-9]+)( +)([0-9]+)( +)([0-9]+)/{print $8}' /opt/SecureSphere/etc/proc/hades/streams)
   sqlhits=$(awk '/(^ +)([0-9]+)( SQL hits\/sec)/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   overloadsqlhits=$(awk '/(^ +)([0-9]+)( overload SQL hits\/sec)/{print $1}' /opt/SecureSphere/etc/proc/hades/status)
   echo "$(date +%Y/%m/%d);$(date +%H:%M);$connection;$httphits;$kbps;$kbpsapp;$overload;$untraceable;$cpu;$ssl_rsa;$ssl_dh;$ssl_ecdh;$streams_streams;$streams_estab;$sqlhits;$overloadsqlhits"
   sleep "$interval"m

done

