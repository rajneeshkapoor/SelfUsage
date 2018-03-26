#!/bin/bash
#set -x

for name in $@; do
    echo "$name" >> services.txt
done
cat > checkStatus.sh <<-EOF
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

while read line
do
    echo -n "	\$line: "
    systemctl status \$line | grep -w active > /dev/null && echo "\${GREEN}running\${NC}" || echo "\${RED}not running\${NC}"
done < /root/services.txt
EOF

node_1="192.168.15.3"
chmod  755 services.txt checkStatus.sh
scp services.txt checkStatus.sh root@${node_1}:/root > /dev/null
rm -f services.txt
rm -f checkStatus.sh

echo "${node_1}"
ssh root@${node_1} "
sh /root/checkStatus.sh
"
set +x
