#!/bin/bash
source $WORKSPACE/build_scripts/config.txt
cd $WORKSPACE

sudo docker build -t kuzuri1194/ankit:django_helloworld .

sudo docker login -u $dockerUser -p $dockerUserPasswd

sudo docker push kuzuri1194/ankit:django_helloworld

