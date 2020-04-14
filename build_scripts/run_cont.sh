#!/bin/bash
source /home/ec2-user/app/build_scripts/config.txt
sudo docker run --name $containerName -id -p 8000:8000 $imageName 
echo 'run ho gaya'