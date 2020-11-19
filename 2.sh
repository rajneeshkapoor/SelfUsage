#!/bin/bash -x
echo "Start 2.sh"

cd /root/RKTrials
wc -l site.yml triliovault_site.yml
echo "" >> triliovault_site.yml && cat triliovault_site.yml >> site.yml
wc -l site.yml triliovault_site.yml

echo "Done 2.sh"
