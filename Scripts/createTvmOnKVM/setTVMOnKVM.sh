validate()
{
	if [ ${ipCount} -ne 1 -a ${ipCount} -ne 3 ]; then
		echo "TVM Machine Count should be 1 or 3"
		read -p "Press enter to continue..."
		iFlag="n"
		return
	fi
	if [ -f ${imagePath} ]; then
		cp ${imagePath} ${imageTargetLoc}
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
setvars()
{
	clear
	iFlag="y"
	imageTargetLoc="/var/lib/libvirt/images"
	tempFile="/tmp/temp.txt"
	read -p "Image tar zip absolute path : " imagePath
	read -p "TVM Machine Count : " ipCount
	validate
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
	cd ${imageTargetLoc}
	tar xvzf ${imageFile}.tar.gz
	for ((iTemp=1;iTemp <= ${ipCount};iTemp++)); do
		cp ${imageFile} ${imageFile}_${iTemp}
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

extractAndCopy

echo "Finally..."
