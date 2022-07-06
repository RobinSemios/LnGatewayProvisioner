
#!/bin/bash

# set -x

####################################################################
#
#   Shell scripts for RAK LN Gateway  provisioning
#
####################################################################

tar -xzf /tmp/Crendential.tar.gz
cd Crendential
mv server.trust /etc/station
mv client.crt /etc/station
mv client.key /etc/station
cd /tmp
tar -xzf /tmp/LnConfig.tar.gz
cd LnConfig
cat networkConfig > /etc/config/lorawan
cat quectelConfig > /etc/config/quectel
sed -i '/auth_mode/d' /etc/config/station
cat stationConfig >> /etc/config/station
cd /tmp
echo "Done provisioning, rebooting the machine"

reboot
