#!/bin/bash

# set -x

####################################################################
#
#   Shell scripts for RAK LoRa gateway provisioning
#
####################################################################

# make sure to provide an ip address!
if [ $# -eq 0 ]; then

    echo "Must provide an IP address to this script."
    exit 1

fi

echo "+------------------------------------------------------------+"
echo "|                     Start provisioning                     |"
echo "+------------------------------------------------------------+"

gtwIp=$1

password=$SEMIOS_PROVISIONER_GWLN_PASSWORD
port=$SEMIOS_PROVISIONER_GWLN_PORT
REMOTE_SCRIPT_NAME=./LN-Remote-Update.sh

if [ ! -f LnMacList ]; then
    echo "Please run (ln-ip-scan.sh ip-list) first!"
    exit 1
fi  

gatewayMac=$(cat LnMacList | grep $gtwIp | awk -F " " '{print $2}') 

if [ ! -f Crendential/client.crt ]; then
    echo "The crendential file 'client.crt' must exist in directory. see README prerequisties!"
    exit 1
fi

if [ ! -f Crendential/client.key ]; then
    echo "The crendential file 'client.key' must exist in directory. see README prerequisties!"
    exit 1
fi

if [ ! -f Crendential/server.trust ]; then
    echo "The crendential file 'server.trust' must exist in directory. see README prerequisties!"
    exit 1
fi

#remove old gz files
rm Crendential.tar.gz
rm LnConfig.tar.gz

#Create latest crendential package and config package for target gateway
tar -czvf Crendential.tar.gz Crendential
tar -czvf LnConfig.tar.gz LnConfig

echo "Logging into the LN gateway @$gtwIp"

# remove ssh key from the provisioining computer
ssh-keygen -f ~/.ssh/known_hosts -R "$gtwIp"

sshpass -p $password ssh -p $port -q -o ConnectTimeout=15 root@$gtwIp -oStrictHostKeyChecking=accept-new exit
if [ ! $? -eq 0 ]; then

  echo "Unable to connect over ssh to gateway @ IP: $gtwIp"
  exit

fi
echo "Logged into the gateway (MAC $gatewayMac) successfully!!"

# create the logs folder if it doesn't exist
[ -d ./logs ] || mkdir ./logs
LOGS_DIR=./logs/$gatewayMac

# create the sub-folder for the mac if it doesn't exist
[ -d $LOGS_DIR ] || mkdir $LOGS_DIR

# remove local logs for this
# gateway if it's run before.
> $LOGS_DIR/stdout
> $LOGS_DIR/stderr

echo "To view status, type tail -f logs/$gatewayMac/stdout in another terminal for the logs in the logs directory..."

{
  sshpass -p $password scp -P $port Crendential.tar.gz root@$gtwIp:/tmp
  sshpass -p $password scp -P $port LnConfig.tar.gz root@$gtwIp:/tmp
  sshpass -p $password scp -P $port LN-Remote-Update.sh root@$gtwIp:/tmp
  # run script in remote gateway
  sshpass -p $password ssh -p $port root@$gtwIp /tmp/$REMOTE_SCRIPT_NAME
} > $LOGS_DIR/stdout 2> $LOGS_DIR/stderr

exit 0