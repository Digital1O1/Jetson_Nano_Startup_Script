#! /bin/bash
echo "Starting intial setup for Jetson Nano"

sudo killall apt apt-get
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a


sudo apt install -y xrdp
sudo apt install -y python3-pip
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev

# Change myUserName to whatever username you're using
sudo adduser ctnano ssl-cert
sudo apt install -y xfce4
sudo chmod 777 /etc/xrdp/startwm.sh
sudo apt-get install -y xfce4-terminal
sudo update-alternatives --config x-terminal-emulator

sudo apt update -y && sudo apt upgrade -y

echo "Use the following commadn : sudo nano /etc/xrdp/startwm.sh"
echo "Comment out the last two lines"
echo "Add 'startxfce4 at the bottom of the file"
echo "Then copy/paste in the terminal :  sudo service xrdp restart"