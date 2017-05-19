#!/bin/bash

# the first argument is the Registration Code of PCoIP agent

# Install the Teradici package key
echo "-->Install the Teradici package key"
rpm --import https://downloads.teradici.com/rhel/teradici.pub.gpg

# Add the Teradici repository
echo "-->Add the Teradici repository"
wget -O /etc/yum.repos.d/pcoip.repo https://downloads.teradici.com/rhel/pcoip.repo

# Update the EPEL repository
echo "-->Update the EPEL repository"
rpm -Uvh --quiet https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

#wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#yum -y install epel-release-latest-7.noarch.rpm

# Install the PCoIP Agent
echo "-->Install the PCoIP Agent"
yum -y update

for idx in {1..3}
do
    yum -y install pcoip-agent-standard
    exitCode=$?
    
    if [ $exitCode -eq 0 ]
    then
        break
    else
        if [ $idx -eq 3 ]
        then
            echo "failed to install pcoip agent."
            exit $exitCode
        else
            yum -y remove pcoip-agent-standard
        fi
    fi
done
    

# register license code
echo "-->Register license code"
for idx in {1..3}
do
    pcoip-register-host --registration-code=$1
    pcoip-validate-license    
    exitCode=$?
    
    if [ $exitCode -eq 0 ]
    then
        break
    else
        if [ $idx -eq 3 ]
        then
            echo "failed to register pcoip agent license."
            exit $exitCode
        fi
    fi
done

# Install Desktop
echo "-->Install desktop"
# yum -y groupinstall "Server with GUI"
yum -y groupinstall 'X Window System' 'GNOME'

echo "-->set default graphical target"
# The below command will change runlevel from runlevel 3 to runelevel 5 
systemctl set-default graphical.target

# skip the gnome initial setup
echo "-->create file gnome-initial-setup-done to skip gnoe initial setup"
for homeDir in $( find /home -mindepth 1 -maxdepth 1 -type d )
do 
    confDir=$homeDir/.config
    mkdir -p $confDir
    chmod 777 $confDir
    echo "yes" | $confDir/gnome-initial-setup-done
    chmod 777 $confDir/gnome-initial-setup-done
done

echo "-->start graphical target"
systemctl start graphical.target