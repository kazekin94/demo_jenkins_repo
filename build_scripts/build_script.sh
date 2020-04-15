#!/bin/bash
source $WORKSPACE/build_scripts/config.txt
cd $WORKSPACE

sudo docker build -t $imageName .

sudo docker tag $imageName 614083026494.dkr.ecr.ap-south-1.amazonaws.com/demo-jenkins/$imageName

$(aws ecr get-login --no-include-email --region $awsRegion )

sudo docker push 614083026494.dkr.ecr.ap-south-1.amazonaws.com/demo-jenkins/$imageName

