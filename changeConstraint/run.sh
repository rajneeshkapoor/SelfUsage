#set -x
clear
fKeysFile="fKeys.txt"
fKeysTables="fKeysTables.txt"
fKeysTablesMod="fKeysTablesMod.txt"
dbName="rk_1"
createTables="createTables.txt"
#dbName="workloadmgr"
infDB="information_schema"

#Foreign key update will take place ONLY if variable exec set to "Y"
exec="Y"

> ${fKeysTables}
> ${fKeysTablesMod}
> ${createTables}

#while read x; do fKeysList="${fKeysList},'$x'"; done < ${fKeysFile}
#fKeysList=${fKeysList:1}
#echo ${fKeysList}
#mysql -e "select CONSTRAINT_NAME, table_name from TABLE_CONSTRAINTS where CONSTRAINT_NAME in (${fKeysList})" information_schema -Ns | sed 's/\t/,/g' > ${fKeysTables}
#cat ${fKeysTables}

dropAndAlterFK()
{
	echo ""
	echo "Change ${fKey} >> ${fKeyDef} << to >> ${fKeyDefNew} <<"
	echo ""
	#mysql -e "alter table marks drop FOREIGN KEY marks_fk_2" rk_1
	#mysql -e "alter table marks add CONSTRAINT marks_fk_2 FOREIGN KEY (subject_id) REFERENCES subjects (id) ON  DELETE CASCADE" rk_1

	echo "mysql -e alter table ${fKeyTable} drop FOREIGN KEY ${fKey} ${dbName}"
	echo "mysql -e alter table ${fKeyTable} add ${fKeyDefNew} ${dbName}"
}
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
		#mysql -e "show create table setting_metadata" workloadmgr | sed 's/-//g;s/+//g;s/\\n/\n/g'
		echo "==================CREATE TABLE START ${fKeyTable} ==================" >> ${createTables}
		echo "==================BEFORE==================" >> ${createTables}
		mysql -e "show create table ${fKeyTable}" ${dbName} | sed 's/-//g;s/+//g;s/\\n/\n/g' >> ${createTables}
		fKeyDefNew=`echo "${fKeyDef} ON CASCADE DELETE"`
		echo ${fKeyDefNew} >> ${fKeysTables}
		if [ ${exec} == "Y" ]
		then
			dropAndAlterFK
		fi
		echo "==================AFTER==================" >> ${createTables}
		mysql -e "show create table ${fKeyTable}" ${dbName} | sed 's/-//g;s/+//g;s/\\n/\n/g' >> ${createTables}
		echo "==================CREATE TABLE END ${fKeyTable} ==================" >> ${createTables}
	else
		echo "Modifying ${fKey} set on ${fKeyTable} with Rule ${fKeyRule} NOT required"
		echo "NOT REQUIRED" >> ${fKeysTables}
		continue
	fi
done < ${fKeysFile}

set +x
