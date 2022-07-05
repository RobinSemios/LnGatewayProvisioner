
#!/bin/bash

# set -x

####################################################################
#
#   Shell scripts for E20 provisioning
#
####################################################################

# make sure to provide an ip address!
gzip -d /tmp/Crendential.tar.gz
tar xf /tmp/Crendential.tar
gzip -d /tmp/LnConfig.tar.gz
tar xf /tmp/LnConfig.tar
mv /tmp/Crendential/server.trust /etc/station
mv /tmp/Crendential/client.crt /etc/station
mv /tmp/Crendential/client.key /etc/station

cat /tmp/LnConfig/networkConfig > /etc/config/lorawan
cat /tmp/LnConfig/quectelConfig > /etc/config/quectel
sed -i '/auth_mode/d' /etc/config/station
cat /tmp/LnConfig/stationConfig >> /etc/config/station
