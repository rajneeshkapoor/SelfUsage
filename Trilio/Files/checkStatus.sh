RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

while read line
do
    echo -n "	$line: "
    systemctl status $line | grep -w active > /dev/null && echo "${GREEN}running${NC}" || echo "${RED}not running${NC}"
done < /root/services.txt
