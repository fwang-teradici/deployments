#!/bin/bash

# the first argument is the Registration Code of PCoIP agent

# install NVIDIA CUDA driver
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup

sudo yum update

echo "-->install kernel-devel"
sudo yum -y install kernel-devel

echo "-->upgrade the EPEL repository"
sudo rpm -Uvh --quiet https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

echo "-->install dkms"
sudo yum -y install dkms

CUDA_REPO_PKG=cuda-repo-rhel7-8.0.61-1.x86_64.rpm

sudo wget http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/${CUDA_REPO_PKG} -O /tmp/${CUDA_REPO_PKG}

echo "-->install cuda repo package"
sudo rpm -ivh /tmp/${CUDA_REPO_PKG}

sudo rm -f /tmp/${CUDA_REPO_PKG}

echo "-->install cuda driver"
sudo yum -y install cuda-drivers

# Install the Teradici package key
echo "-->Install the Teradici package key"
sudo rpm --import https://downloads.teradici.com/rhel/teradici.pub.gpg

# Add the Teradici repository
echo "-->Add the Teradici repository"
sudo wget -O /etc/yum.repos.d/pcoip.repo https://downloads.teradici.com/rhel/pcoip.repo

# Install the EPEL repository, this step is done when installing video driver, so skip it

# Install the PCoIP Agent
echo "-->Install the PCoIP Graphics Agent"

for idx in {1..3}
do
    sudo yum -y install pcoip-agent-graphics
    exitCode=$?
    
    if [ $exitCode -eq 0 ]
    then
        break
    else
        sudo yum -y remove pcoip-agent-graphics
        if [ $idx -eq 3 ]
        then
            echo "failed to install pcoip agent."
            exit $exitCode
        fi
    fi
done
    

# register license code
echo "-->Register license code"
for idx in {1..3}
do
    sudo pcoip-register-host --registration-code=$1
    sudo pcoip-validate-license    
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
sudo yum -y groupinstall 'X Window System' 'GNOME'

echo "-->set default graphical target"
# The below command will change runlevel from runlevel 3 to runelevel 5 
sudo systemctl set-default graphical.target

# skip the gnome initial setup
echo "-->create file gnome-initial-setup-done to skip gnoe initial setup"
for homeDir in $( find /home -mindepth 1 -maxdepth 1 -type d )
do 
    confDir=$homeDir/.config
    sudo mkdir -p $confDir
    sudo chmod 777 $confDir
    echo "yes" | sudo tee $confDir/gnome-initial-setup-done
    sudo chmod 777 $confDir/gnome-initial-setup-done
done

echo "-->start graphical target"
sudo systemctl start graphical.target

sudo shutdown -r +1
exit 0