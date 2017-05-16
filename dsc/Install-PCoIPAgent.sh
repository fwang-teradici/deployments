#!/bin/bash

# the first argument is the Registration Code of PCoIP agent

# Install the Teradici package key

logger "Install the Teradici package key"
rpm --import https://downloads.teradici.com/rhel/teradici.pub.gpg#Add the Teradici repositorylogger "Add the Teradici repository"
wget -O /etc/yum.repos.d/pcoip.rep https://downloads.teradici.com/rhel/pcoip.repo
#Install the EPEL repository
logger "Install the EPEL repository"
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -i epel-release-latest-7.noarch.rpm
#Install the PCoIP Agent
logger "Install the PCoIP Agent"
yum update
yum install pcoip-agent-standard#register license codelogger "register license code"
pcoip-register-host --registration-code=@1