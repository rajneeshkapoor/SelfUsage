#set -x
clear
fKeysFile="fKeys.txt"
fKeysTables="fKeysTables.txt"
#dbName="rk_1"
dbName="workloadmgr"
infDB="information_schema"

#Foreign key update will take place ONLY if variable exec set to "Y"
exec="n"

> ${fKeysTables}

#while read x; do fKeysList="${fKeysList},'$x'"; done < ${fKeysFile}
#fKeysList=${fKeysList:1}
#echo ${fKeysList}
#mysql -e "select CONSTRAINT_NAME, table_name from TABLE_CONSTRAINTS where CONSTRAINT_NAME in (${fKeysList})" information_schema -Ns | sed 's/\t/,/g' > ${fKeysTables}
#cat ${fKeysTables}

while read fKey
do
	fKeyData=`mysql -e "select CONSTRAINT_NAME, DELETE_RULE, TABLE_NAME from REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = '${fKey}'" ${infDB} -Ns | sed 's/\t/,/g' `
	echo -n "${fKeyData}," >> ${fKeysTables}
	fKeyRule=`echo ${fKeyData} | cut -d"," -f2`
	fKeyTable=`echo ${fKeyData} | cut -d"," -f3`

	mysql -e "show create table ${fKeyTable}" ${dbName} -Ns | sed 's/\t/ /g' | cut -d" " -f2- | sed 's/\\n/\n/g' | grep ${fKey} | sed "s/\`//g;s/,$//g;s/^  //g" > temp
	fKeyDef=`cat temp`
	echo -n "${fKeyDef}," >> ${fKeysTables}
	
	if [ ${fKeyRule} == "RESTRICT" ]
	then
		fKeyDefNew=`echo "${fKeyDef} ON CASCADE DELETE"`
		echo ${fKeyDefNew} >> ${fKeysTables}
	else
		echo "Modifying ${fKey} set on ${fKeyTable} with Rule ${fKeyRule} NOT required"
		echo "NOT REQUIRED" >> ${fKeysTables}
		continue
	fi
done < ${fKeysFile}

set +x
