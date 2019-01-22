#set -x
setVars()
{
	baseDir="/tmp"
	varsFile="${baseDir}/inputData/vars.txt"
	tvmPwd="52T8FVYZJse"
	sendmail="/usr/sbin/sendmail"
	workloadFile="${baseDir}/inputData/WLs.txt"
	#workloadFile will be having list of Workload IDs; one ID per line
	workloadList=`awk 'NF { print "\""$0"\""}' $workloadFile | tr '\n' ',' | sed '$s/,$//'`
	selectCols="W.DISPLAY_NAME AS WORKLOAD_NAME,S.WORKLOAD_ID,S.DISPLAY_NAME as SNAPSHOT_NAME,S.ID as SNAPSHOT_ID,S.STATUS as SNAPSHOT_STATUS,S.CREATED_AT,S.UPDATED_AT,S.ERROR_MSG"
	sqlOut="${baseDir}/queryOut.csv"
	htmlOUT="${baseDir}/file.html"
	rm -f ${sqlOut} ${htmlOUT}
	#sqlColsDel="#" >> UNUSED YET
	targetTVault=`grep targetTVault ${varsFile} | awk -F'=' '{print $2}' | head -1`
	mailIDs="rajneesh.kapoor@trilio.io,rajneesh.kapoor@afourtech.com,deepali.pharande@trilio.io,omkar.nawghare@trilio.io"
	#mailIDs="rajneesh.kapoor@trilio.io"
}

genHTML()
{
	#sshpass -p52T8FVYZJse  ssh -o StrictHostKeyChecking=no root@149.56.121.111 date
	tvmDate=`sshpass -p${tvmPwd}  ssh -o StrictHostKeyChecking=no root@${targetTVault} date`
	echo "Subject: RHV Report [${tvmDate}]" > ${htmlOUT}
	echo "To: ${mailIDs}" >> ${htmlOUT}
	awk 'BEGIN{
	#Replace by variable pending
	FS="#"
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
	mysql -e "select ${selectCols} from workloads W INNER JOIN snapshots S on W.id = S.workload_id where W.id in ($workloadList) order by S.created_at desc" | sed "s/\t/#/g" > ${sqlOut}
	genHTML
}

sendReport()
{
	${sendmail} ${mailIDs} < ${htmlOUT}
}

setVars
execAndGenReport
sendReport
#awk 'NF { print "\""$0"\""}' WLs.txt | tr '\n' ','
set +x
