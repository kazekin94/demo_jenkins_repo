#!/bin/bash
source /home/ec2-user/app/build_scripts/config.txt
sudo docker stop $containerName
sudo docker rm -f $containerName
sudo docker rmi -f $imageName