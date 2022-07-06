if [ $# -eq 0 ]; then

    echo "Must provide an IP address to this script."
    exit 1

fi

echo "+------------------------------------------------------------+"
echo "|                     Start provisioning                     |"
echo "+------------------------------------------------------------+"

gtwy_ip=$1

password=$SEMIOS_PROVISIONER_GWLN_PASSWORD
port=$SEMIOS_PROVISIONER_GWLN_PORT
echo "pass is $password"
echo "port is $port"

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

echo "Logging into the LN gateway @$gtwy_ip"
ssh-keygen -f ~/.ssh/known_hosts -R "$gtwy_ip"
sshpass -p $password ssh -p $port -q -o ConnectTimeout=15 root@$gtwy_ip -oStrictHostKeyChecking=accept-new exit
if [ ! $? -eq 0 ]; then

  echo "Unable to connect over ssh to gateway @ IP: $gtwy_ip"
  exit

fi

sshpass -p $password scp -P $port Crendential.tar.gz root@$gtwy_ip:/tmp
sshpass -p $password scp -P $port LnConfig.tar.gz root@$gtwy_ip:/tmp
sshpass -p $password scp -P $port LN-Remote-Update.sh root@$gtwy_ip:/tmp
