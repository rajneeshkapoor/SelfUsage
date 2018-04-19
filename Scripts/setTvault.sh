echo "Setting Mysql"
cat << EOF > $HOME/.my.cnf
[mysql]
user=root
password=52T8FVYZJse
database=workloadmgr
EOF
echo "alias m='mysql -e'" >> $HOME/.profile
. $HOME/.profile
echo "Current Date/time from MySql"
m "select curdate(), curtime()"
