#set -x
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

cleanUp()
{
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		rm -f ${TVAULT_ISO}_${iTemp}.iso ${USER_DATA}_${iTemp} ${META_DATA}_${iTemp}
	done
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
	cat > ${USER_DATA} << _EOF_
preserve_hostname: False
hostname: ${tvmName}_${iTemp}
_EOF_
}

setMetaData()
{
	cat > ${META_DATA} << _EOF_
instance-id: ${tvmName}_${iTemp}
network-interfaces: |
  auto ens3
  iface ens3 inet static
  address ${ip[${iTemp}]}
  netmask 255.255.0.0
  gateway 192.168.1.1
  dns-nameservers 192.168.1.1 8.8.8.8
hostname: ${tvmName}_${iTemp}
_EOF_
}

setISO()
{
	genisoimage -output ${TVAULT_ISO}_${iTemp}.iso -volid cidata -joliet -rock ${USER_DATA} ${META_DATA}
	cp ${USER_DATA} ${USER_DATA}_${iTemp}; cp ${META_DATA} ${META_DATA}_${iTemp}
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
		virt-install --import --name ${tvmName}_${iTemp} --memory $MEM --vcpus $CPUs --disk ${imageFile}_${iTemp},format=qcow2,bus=virtio --disk ${TVAULT_ISO}_${iTemp}.iso,device=cdrom --network  bridge=virbr0,model=virtio --os-type=linux --noautoconsole
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

cleanUp
setDataFiles
extractAndCopy
createVMs


echo "Finally..."
set +x
