#!/bin/bash
source $WORKSPACE/build_scripts/config.txt
cd $WORKSPACE

sudo docker build -t django_helloworld:latest .

$(aws ecr get-login --no-include-email --region $awsRegion)

sudo docker tag django_helloworld:latest $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com/$imageName

sudo docker push $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com/$imageName

