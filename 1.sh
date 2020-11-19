#!/bin/bash -x
echo "Start"
ssh -q -o "StrictHostKeyChecking no" root@$172.25.1.102 'bash -sx' < 2.sh
echo "Done"
