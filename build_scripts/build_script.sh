#!/bin/bash
source $WORKSPACE/build_scripts/config.txt
cd $WORKSPACE

sudo docker build -t kuzuri1194/ankit:django_helloworld .

echo "Get para user name"
ssmGetParaName=$(aws ssm get-parameter --name "docker-username" --region $awsRegion | grep Value | tr -d Value | tr -d '"' | tr -d ',' | tr -d ':' | awk '{$1=$1};1'  )
echo $ssmGetParaName

echo "Get para password"
ssmGetParaPwd=$(aws ssm get-parameter --name "docker-password" --region $awsRegion | grep Value | tr -d Value | tr -d '"' | tr -d ',' | tr -d ':' | awk '{$1=$1};1'  )
echo $ssmGetParaPwd

sudo docker login -u $ssmGetParaName -p $ssmGetParaPwd

sudo docker push kuzuri1194/ankit:django_helloworld

