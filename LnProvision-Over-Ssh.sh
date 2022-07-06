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

if [ ! -f LnMacList ]; then
    echo "Please run (ln-ip-scan.sh ip-list) first!"
    exit 1
else
    
gatewayMac=$(cat LnMacList | grep $gtwIP | awk -F " " '{print $2}') 

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
ssh-keygen -f ~/.ssh/known_hosts -R "$gtwIp"
sshpass -p $password ssh -p $port -q -o ConnectTimeout=15 root@$gtwIp -oStrictHostKeyChecking=accept-new exit
if [ ! $? -eq 0 ]; then

  echo "Unable to connect over ssh to gateway @ IP: $gtwIp"
  exit

fi

sshpass -p $password scp -P $port Crendential.tar.gz root@$gtwIp:/tmp
sshpass -p $password scp -P $port LnConfig.tar.gz root@$gtwIp:/tmp
sshpass -p $password scp -P $port LN-Remote-Update.sh root@$gtwIp:/tmp
