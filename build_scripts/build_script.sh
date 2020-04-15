#!/bin/bash
source $WORKSPACE/build_scripts/config.txt
cd $WORKSPACE

sudo docker build -t $imageName .

sudo docker tag $imageName $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com/$imageName

aws ecr get-login-password --region $awsRegion | docker login --username AWS --password-stdin $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com

sudo docker push $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com/$imageName

