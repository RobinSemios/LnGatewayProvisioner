if [ $# -eq 0 ]; then

    echo "Must provide an IP address to this script."
    exit 1

fi

echo "+------------------------------------------------------------+"
echo "|                     Start provisioning                     |"
echo "+------------------------------------------------------------+"

#Create the crendential package and config package for target gateway
tar -czvf Crendential.tar.gz Crendential
tar -czvf LnConfig.tar.gz LnConfig

gtwy_ip=$1
password="root"
port="22"
echo "Logging into the LN gateway @$gtwy_ip"
# remove ssh key from the provisioining computer
ssh-keygen -f ~/.ssh/known_hosts -R "[$gtwy_ip]:22"
