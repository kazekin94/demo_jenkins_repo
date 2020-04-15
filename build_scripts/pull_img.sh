#!/bin/bash
source /home/ec2-user/app/build_scripts/config.txt
sudo docker login -u $dockerUser -p $dockerUserPasswd
echo 'image name'
echo $imageName
sudo docker rm -f $imageName  
sleep 10
sudo docker pull $imageName