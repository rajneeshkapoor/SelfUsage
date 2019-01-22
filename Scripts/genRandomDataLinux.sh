#!/usr/bin/sh
#set -x
maxThreshold=80
#File size will be [$blockSize * $count]
blockSize=1048576
count=1024

diskUsed=`df -h | grep -w "/" | head -1 | awk '{print $(NF-1)}' | cut -d"%" -f1`
if [ `echo ${diskUsed} | cut -d"%" -f1` -lt ${maxThreshold} ]
then 
	dd if=/dev/urandom of=/tmp/file_`date +%s`.txt bs=${blockSize} count=${count}
else
	echo "SKIPPED as File System ${maxThreshold}% full"
fi
set +x
