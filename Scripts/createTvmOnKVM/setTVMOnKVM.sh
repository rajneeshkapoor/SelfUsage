setvars()
{
	clear
	iFlag="y"
	USER_DATA="/tmp/user-data"
	META_DATA="/tmp/meta-data"
	TVAULT_ISO="/tmp/tvault"
	MEM=6000
	CPUs=4
	BRIDGE=`brctl show | awk '{print $1}' | head -2 | tail -1`
	imageTargetLoc="/var/lib/libvirt/images"
	tempFile="/tmp/temp.txt"
	read -p "Image tar zip absolute path : " imagePath
	read -p "TVM Machine Count : " ipCount
	read -p "TVM Machine Hostname (Multiple TVMs will be appended with machine count): " tvmName
	validate
}

validate()
{
	if [ ${ipCount} -ne 1 -a ${ipCount} -ne 3 ]; then
		echo "TVM Machine Count should be 1 or 3"
		read -p "Press enter to continue..."
		iFlag="n"
		return
	fi
	if [ -f ${imagePath} ]; then
		echo ${imagePath} >> ${tempFile}
		if [ `grep "ha" ${tempFile}` ]; then
			imageFile=`ls ${imagePath} | awk -F'/' '{print $NF}' | cut -d"." -f1-5`
		else
			imageFile=`ls ${imagePath} | awk -F'/' '{print $NF}' | cut -d"." -f1-4`
		fi
		rm -f ${tempFile}
	else
		echo "${imagePath} does not exists"
		read -p "Press enter to continue..."
		iFlag="n"
	fi
}

setips()
{
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		read -p "Enter IP ${iTemp}: " ip[${iTemp}]
	done
}

showvars()
{
	echo "Values Setup...."
	echo "Image Location : ${imagePath}"
	echo "Image File : ${imageFile}"
	echo "TVM machines Count : ${ipCount}"
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		echo "IP Address ${iTemp} : ${ip[${iTemp}]}"
	done
}

extractAndCopy()
{
	cp ${imagePath} ${imageTargetLoc}
	cd ${imageTargetLoc}
	tar xvzf ${imageFile}.tar.gz
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		cp ${imageFile} ${imageFile}_${iTemp}
	done
}

setUserData()
{
	cat > ${USER_DATA}_${iTemp} << _EOF_
preserve_hostname: False
hostname: ${tvmName}_${iTemp}
# Remove cloud-init when finished with it
runcmd:
  - [ yum, -y, remove, cloud-init ]
# Configure where output will go
output: 
  all: ">> /var/log/cloud-init.log"
# configure interaction with ssh server
ssh_svcname: ssh
ssh_deletekeys: True
ssh_genkeytypes: ['rsa', 'ecdsa']
# Install my public ssh key to the first user-defined user configured 
# in cloud.cfg in the template (which is centos for CentOS cloud images)
ssh_authorized_keys:  
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfNePSyLNJ7UOvThXb75fyEh6GbYhHHkAkqvTZexGFC2WwPi0aPNRxMlf8pSHEHtowFz90l+KFqQuwurSqGfCCBM/PvhFaCFcUASVrcNPO8SCt8nDoDM5Ir6lrv5qd/WX63ODsQzs/HIC3TVK75nxIMSI46Yde1v2Kha3pe0JD7Tt0NdJFVq2eTsGaK9oMeuZcpR2OkfQDdGb4YeDshrvU011XEMez8hG2mqi39hKJIqZcvq/Z0h7ECIp/nP+ypGOYwWDd/Sab5/UkluqkL3LUK69XKrrdPjlw/COe5qZ2x8Gi86MneELRoOYb4iEfA6f1m/PBvcB9SeNQyiLzDzSB root@localhost.localdomain
_EOF_
}

setMetaData()
{
	cat > ${META_DATA}_${iTemp} << _EOF_
instance-id: ${tvmName}_${iTemp}
network-interfaces: |
auto ens3
iface ens3 inet static
address ${ip[${iTemp}]}
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 192.168.1.1 8.8.8.8
local-hostname: ${tvmName}_${iTemp}
_EOF_
}

setISO()
{
	genisoimage -output ${TVAULT_ISO}_${iTemp}.iso -volid cidata -joliet -rock ${USER_DATA}_${iTemp} ${META_DATA}_${iTemp}
}

setDataFiles()
{
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		setUserData
		setMetaData
		setISO
	done
}

createVMs()
{
	cd ${imageTargetLoc}
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		virt-install --import --name ${tvmName}_${iTemp} --memory $MEM --vcpus $CPUs --disk ${imageFile}_${iTemp},format=qcow2,bus=virtio --disk ${TVAULT_ISO}_${iTemp}.iso,device=cdrom --network  bridge=virbr0,model=virtio --os-type=linux --os-variant=rhel7 --noautoconsole
		virsh change-media ${tvmName}_${iTemp} hda --eject --config
	done
}

while [ true ]
do
	setvars
	if [ ${iFlag} == "n" ]
	then
		continue
	fi
	setips
	showvars
	read -p "Confirm? y or n : " iFlag
	if [ ${iFlag} == "y" -o ${iFlag} == "Y" ]
	then
		echo "Continuing with values specified above ..."
		break
	else
		echo "Enter values again..."
	fi
done

setDataFiles
#extractAndCopy
createVMs


echo "Finally..."
