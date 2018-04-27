while read line
do
	echo $line
	mysqldbcompare --server1=root:a2623f27531b4c91@localhost --server2=root:52T8FVYZJse@192.168.15.10 $line:$line --skip-diff --run-all-tests > $line.out
done < dbs
