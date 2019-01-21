#set -x
setVars()
{
	workloadFile="inputData/WLs.txt"
	#workloadFile will be having list of Workload IDs; one ID per line
	workloadList=`awk 'NF { print "\""$0"\""}' $workloadFile | tr '\n' ',' | sed '$s/,$//'`
	selectCols="W.DISPLAY_NAME,S.WORKLOAD_ID,S.ID as SNAPSHOT_ID,S.STATUS,S.CREATED_AT,S.UPDATED_AT,S.ERROR_MSG"
	sqlOut="queryOut.csv"
	htmlOUT="file.html"
	rm -f ${sqlOut} ${htmlOUT}
	mailIDs="rajneesh.kapoor@trilio.io,rajneesh.kapoor@afourtech.com,deepali.pharande@trilio.io,omkar.nawghare@trilio.io"
}

genHTML()
{
	echo "Subject: RHV Report [`date`]" > ${htmlOUT}
	echo "To: ${mailIDs}" >> ${htmlOUT}
	awk 'BEGIN{
	FS=","
	print  "From: RHVScale@trilio.io"
	print  "MIME-Version: 1.0"
	print  "Content-Type: text/html"
	print  "Content-Disposition: inline"
	print  "<HTML>""<TABLE border="1">"
	}
 	{
	printf "<TR>"
	for(i=1;i<=NF;i++)
	printf "<TD>%s</TD>", $i
	print "</TR>"
 	}
	END{
	print "</TABLE></BODY></HTML>"
 	}
	' ${sqlOut} >> ${htmlOUT}
}

execAndGenReport()
{
	mysql -e "select ${selectCols} from workloads W INNER JOIN snapshots S on W.id = S.workload_id where W.id in ($workloadList) order by S.created_at desc" | sed "s/\t/,/g" > ${sqlOut}
	genHTML
}

sendReport()
{
	sendmail ${mailIDs} < ${htmlOUT}
}

setVars
execAndGenReport
sendReport
#awk 'NF { print "\""$0"\""}' WLs.txt | tr '\n' ','
set +x
