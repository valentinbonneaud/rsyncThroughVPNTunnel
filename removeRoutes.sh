#!/bin/sh

. ./utils.sh

isSudo

if [ ! "$?" = "0" ]; then
	echo "I need sudo to run !"
	echo "Exiting ..."
	exit 0
fi

if [ ! -f "PID_VPN.txt" ]; then 
	echo "The VPN info files don't exist";
	exit 
fi

PID_VPN=$(cat "PID_VPN.txt")
target=$(cat "target.txt")
ip=$(cat "ip.txt")
ip_tun=$(cat "ip_tun.txt")
defaultGetway=$(cat "defaultGetway.txt")

rm -f "PID_VPN.txt" "target.txt" "ip.txt" "ip_tun.txt" "defaultGetway.txt" 

echo "End of the business"
echo "-------------------"

echo "killing $PID_VPN"
kill $PID_VPN

while kill -0 $PID_VPN; do
	echo "still alive"
	kill $PID_VPN
done

ip route delete "$target"/32 via "$ip_tun"
ip route delete "$ip"/32 via "$defaultGetway"

echo "-------------------"

ipGoogle=$(dig +short -t a "google.com")

echo "Test Routing"
ip route get "$target"
ip route get "$ipGoogle"
echo "-------------------"
