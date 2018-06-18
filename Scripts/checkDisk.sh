#!/usr/bin/sh
#set -x
maxThreshold=80
subject="ALERT MAIL"
mailIds="rajneesh.kapoor@trilio.io,sachin.kulkarni@trilio.io,priyanka.palkar@trilio.io"
mailFile=/tmp/mailText.txt
rm -f ${mailFile}

diskUsed=`df -h | grep -w "/" | head -1 | awk '{print $(NF-1)}' | cut -d"%" -f1`
if [ `echo ${diskUsed} | cut -d"%" -f1` -gt ${maxThreshold} ]
then 
	echo "#############Alert######################" > ${mailFile}
	echo "`date`" >> ${mailFile}
	echo "${diskUsed}% used on `hostname -I`" >> ${mailFile}
	echo "Details :" >> ${mailFile}
	df -h >> ${mailFile}
	echo "########################################" >> ${mailFile}	
	mail -s "${subject}" "${mailIds}" < ${mailFile}
fi
set +x
