#!/bin/bash
source $WORKSPACE/build_scripts/config.txt
cd $WORKSPACE

sudo docker build -t $imageName .

sudo docker tag $imageName $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com/$imageName

$(aws ecr get-login --no-include-email --region $awsRegion)

sudo docker push $awsAccountId.dkr.ecr.$awsRegion.amazonaws.com/$imageName

