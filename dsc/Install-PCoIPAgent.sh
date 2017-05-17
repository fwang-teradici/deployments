#!/bin/bash

# the first argument is the Registration Code of PCoIP agent

# Install desktop
echo "-->Install desktop"
# install the whole GUI and Additional Tools
# sudo yum -y groupinstall "Server with GUI"
# just install the gnome desktop 
sudo yum -y groupinstall 'X Window System' 'GNOME'

# Install the Teradici package key
echo "-->Install the Teradici package key"
sudo rpm --import https://downloads.teradici.com/rhel/teradici.pub.gpg

# Add the Teradici repository
echo "-->Add the Teradici repository"
sudo wget -O /etc/yum.repos.d/pcoip.repo https://downloads.teradici.com/rhel/pcoip.repo

# Install the EPEL repository
echo "-->Install the EPEL repository"
sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install epel-release-latest-7.noarch.rpm

# Install the PCoIP Agent
echo "-->Install the PCoIP Agent"
sudo yum -y update

for idx in {1..3}
do
    sudo yum -y install pcoip-agent-standard
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
            sudo yum -y remove pcoip-agent-standard
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

# skip the gnome initial setup
mkdir -p  ~/.config
echo "yes" >> ~/.config/gnome-initial-setup-done

# start GUI
sudo systemctl set-default graphical.target
sudo systemctl start graphical.target