#!/bin/bash
echo "Hello tuxnoobdotcom!"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y figlet toilet
sudo echo "Banner /etc/motd" >> /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo figlet broom-id > /etc/motd

sudo apt install -y s3fs
sudo reboot
