#!/bin/sh

. ./utils.sh

lockFile=$(getParam "lockFile")
targetUser=$(getParam "targetUser")
target=$(getParam "target")
targetPath=$(getParam "targetPath")
localPath=$(getParam "localPath")

isSudo

if [ ! "$?" = "0" ]; then
	echo "I need sudo to run !"
	echo "Exiting ..."
	exit 0
fi

getFiles_core() {

	if [ -f "$lockFile" ]; then
		echo "Lock file exists ... exiting ..."
		return 0
	fi

	touch "$lockFile"

	./addRoutes.sh

	if [ ! "$?" = "0" ]; then
		echo "Error when opening the VPN connection, exiting ...."
		return 1
	fi



	ssh -o ConnectTimeout=10 "$targetUser"@"$target" "ls $targetPath" | while read -r line; do 
		echo "new file to download: $f"
		rsync -avhPSL "$targetUser"@"$target":"$targetPath/$f" "$localPath"
		if [ $? -eq 0 ]; then
			ssh "$targetUser"@"$target" "rm -r $targetPath/$f"
		else
			echo "Something strange happened during the rsync of $f"
		fi
	done

	./removeRoutes.sh
	if [ ! "$?" = "0" ]; then
		echo "Error when closing the VPN connection, exiting ...."
		return 3
	fi

	rm "$lockFile"

	return 0

}

getFiles_core
returnValue=$?

if [ ! "$returnValue" = "0" ]; then
	rm -f "$lockFile"
	./removeRoutes.sh
fi
