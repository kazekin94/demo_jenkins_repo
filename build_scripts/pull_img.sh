#!/bin/bash
source /home/ec2-user/app/build_scripts/config.txt
$(aws ecr get-login --no-include-email --region $awsRegion)
echo 'image name'
echo $imageName
sudo docker rm -f $imageName  
sleep 10
sudo docker pull $imageName