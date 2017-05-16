#!/bin/bash

# the first argument is the Registration Code of PCoIP agent

# Install the Teradici package key
echo "-->Install the Teradici package key"
sudo rpm --import https://downloads.teradici.com/rhel/teradici.pub.gpg

# Add the Teradici repository
echo "-->Add the Teradici repository"
sudo wget -O /etc/yum.repos.d/pcoip.repo https://downloads.teradici.com/rhel/pcoip.repo

# Install the EPEL repository
echo "-->Install the EPEL repository"
sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -i -q epel-release-latest-7.noarch.rpm

# Install the PCoIP Agent
echo "-->Install the PCoIP Agent"
sudo yum -y update
sudo yum -y install pcoip-agent-standard

# register license code
echo "-->Register license code"
pcoip-register-host --registration-code=@1
pcoip-validate-license