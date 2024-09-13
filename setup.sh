#!/bin/bash

##########################################################
# SETS UP DOCKER IMAGE REQS ON A NEW RPI
# - Run this script on a newly flashed Raspberry Pi 5.
#   After running it, run 'compose.sh' to load in and run
#   the most current image
##########################################################

function printInfo {
  echo -e "\033[0m\033[36m[INFO] $1\033[0m"
}

function printWarning {
  echo -e "\033[0m\033[33m[WARNING] $1\033[0m"
}

function printError {
  echo -e "\033[0m\033[31m[ERROR] $1\033[0m"
}

# Install Docker if not already installed
if ! [ -x "$(command -v docker)" ]; then
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh

    sudo usermod -aG docker agrobot
else

    echo ""
    printWarning "Docker is already installed"
    echo ""
fi

# Install dependencies
sudo apt update
sudo apt upgrade -y
sudo apt install -y vim tmux git rsync

# Set up udev rules
sudo cp /home/agrobot/AgrobotSetup/config/local/00-teensy.rules /etc/udev/rules.d/00-teensy.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Set up config files
cp ~/AgrobotSetup/config/local/.tmux.conf ~/.tmux.conf

# Copy repos from GitHub
cd ~
git clone https://github.com/BYUAgrobotics/AgrobotRPi.git
git clone https://github.com/BYUAgrobotics/AgrobotTeensy.git

# Set up volumes
mkdir ~/bag
cp -r ~/AgrobotSetup/config ~

echo ""
printInfo "Make sure to set the robot-specific params in 'robot_config.yaml' in '~/config' now"
echo ""
