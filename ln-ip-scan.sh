
#!/bin/bash

##########################################################################
#
#   IP scanner for the LoRa gateways
#
#   This acript doesn't work with IPV6. Please turn off IPV6 support from
#   your computer. If you have wireless connection turned on, please turn
#   it off.
#
##########################################################################

ipList=""

if [ $# -ne 0 ]; then

    ipList=$1

fi

# filter out wifi subnet
subnet=$(sudo ip route | grep default | awk -F "via " '{print $2}'| awk -F ".1 dev" '{print $1}')

version=$(lsb_release -rs)
echo "Found Ubuntu $version"

# obatin IPs for MAC address begin with AC:1F for RAK LN gateway mac standard 
ips=$(sudo arp-scan "192.168.1.0/24" | grep "ac:1f" | awk -F " " '{print $1}')
ipMacInfo=$(sudo arp-scan "192.168.1.0/24" | grep "ac:1f")
printf "%s\n" "${ipMacInfo[@]}" > LnMacList
sed -e 's/:/FFE/3' -e 's/://g' -i LnMacList
echo "Subnet: $subnet"
echo "Found LN gateway Ip address:"

if [ -z "$ips" ]; then

    echo "No IP found"

else

    if [[ "$ipList" = "" ]]; then

        printf "%s\n" "${ips[@]}"
    else

        printf "%s\n" "${ips[@]}" > $ipList

    fi

fi