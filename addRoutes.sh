#!/bin/sh

. ./utils.sh

isSudo

if [ ! "$?" = "0" ]; then
	echo "I need sudo to run !"
	echo "Exiting ..."
	exit 0
fi

configFileVPN=$(getParam "configFileVPN")
target=$(getParam "target")

# we extract and resolve the VPN server name
vpnServer=$(cat $configFileVPN | awk '/remote/ { print $2 }')
ip=$(dig +short -t a "$vpnServer")
# we extract the current default gateway
defaultGetway=$(ip route | grep "default" | awk '/default/ {print $3}' | head -n 1)

# we first check if there are any openvpn running
PID_VPN=$(ps axf | grep "[o]penvpn" | head -n 1 | cut -d ' ' -f1)
while [ $PID_VPN ]; do
	echo "killing $PID_VPN"
	kill "$PID_VPN"
	PID_VPN=$(ps axf | grep "[o]penvpn" | head -n 1 | cut -d ' ' -f1)
done

# we launch the vpn connection and wait that the connection is successful
openvpn --config "$configFileVPN" --route-noexec &
PID_VPN=$!
sleep 15

# we extract the ip of the tunnel
ip_tun=$(ip route | grep tun | cut -d ' ' -f1)

echo "PID VPN = $PID_VPN"
echo "IP of the VPN = $ip"
echo "Default getway = $defaultGetway"

# we add the route to redirect the packet to the vpn on the default gateway
ip route add "$ip"/32 via "$defaultGetway"
# we route the packet for our target to the tunnel
ip route add "$target"/32 via "$ip_tun"

echo "-------------------"

ipGoogle=$(dig +short -t a "google.com")

echo "Test Routing"
ip route get "$target"
ip route get "$ipGoogle"
echo "-------------------"

echo "-------------------"
echo "Start the business"


echo "$PID_VPN" >  "PID_VPN.txt"
echo "$target" > "target.txt"
echo "$ip" > "ip.txt"
echo "$ip_tun" > "ip_tun.txt"
echo "$defaultGetway" > "defaultGetway.txt"

