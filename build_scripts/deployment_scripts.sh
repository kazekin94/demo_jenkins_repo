#!/bin/bash
source $WORKSPACE/build_scripts/config.txt

#filename=$(cat $WORKSPACE/filename.txt)

#echo 'deployment script'
#echo $filename

KEY=`aws s3 ls $artifactBucketName --recursive | sort | tail -n 1 | awk '{print $4}'`
#filename=$(cat $WORKSPACE/b.txt)
echo 's3 resp'
echo $KEY

echo "deployment mode is : $deploymentMode"

if [ $deploymentMode == "stale" ]
then
    #deploy to stale instance
    dp_id=$(aws deploy create-deployment --application-name "$deploymentApplication" --deployment-group-name $deploymentGroupName --region $awsRegion --s3-location  bucket=$artifactBucketName,bundleType=zip,key=$KEY  | grep deploymentId | tr -d \ \"\,| sed 's/.*://g')
    echo "Deployment created : $dp_id "
    sleep 5
    echo 'getting deployment status'
    dp_id_resp=$(aws deploy get-deployment --deployment-id $dp_id --region $awsRegion | grep status | tr -d \ \"\,| sed 's/.*://g')
    echo $dp_id_resp
    
    var=0
    while true
    do dp_id_resp=$(aws deploy get-deployment --deployment-id $dp_id --region $awsRegion | grep status | tr -d \ \"\,| sed 's/.*://g')
        var=$((var+1))
        
        if [ $var == 61 ]
        then
            echo "deployment failed within 30 minutes"
            exit 1
        fi
        
        if [ $dp_id_resp == "Succeeded" ]
        then
            echo "deployment successful, exited"
            exit 0
        elif [ $dp_id_resp == "Failed" ] 
        then    
            echo "deployment failed, exited"
            exit 1
        elif [ $dp_id_resp == "Stopped" ] 
        then
            echo "deployment stopped"
            exit 1
        else
            echo "Checking deployment status, please wait."
                sleep 30
        fi
    done

elif [ $deploymentMode == "fresh" ]
then
    lcNameFresh=fresh-deployment-lc
    asgNameFresh=fresh-deployment-asg
    #create lc
    echo "creating lc"
    createLc=$(aws autoscaling create-launch-configuration --launch-configuration-name $lcNameFresh --image-id $amiId --instance-type t2.micro --key-name jenkins-slave --iam-instance-profile CodeDeployDemo-EC2-Instance-Profile --associate-public-ip-address --security-groups sg-087ae0c8b494e6b39 --region $awsRegion )
    sleep 10
    echo "lc created"
    #create asg from lc
    echo "creating asg"
    createAsg=$(aws autoscaling create-auto-scaling-group --auto-scaling-group-name $asgNameFresh --launch-configuration-name $lcNameFresh --min-size 1 --max-size 2 --desired-capacity 1 --vpc-zone-identifier "subnet-0c50a45327af442ac, subnet-0c989e6010eaeffbc" --region $awsRegion)
    sleep 10
    describeFreshAsg=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name fresh-deployment-asg  --region $awsRegion | grep LifecycleState | awk '{$1=$1};1' | tr -d '"' | tr -d ',' | sed 's/LifecycleState: //')
    echo "Asg created, instace status $describeFreshAsg"
    if [ $describeFreshAsg != 'InService' ]
    then
        while true
        do describeFreshAsg=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name fresh-deployment-asg  --region $awsRegion | grep LifecycleState | awk '{$1=$1};1' | tr -d '"' | tr -d ',' | sed 's/LifecycleState: //')
            if [ $describeFreshAsg == 'InService' ]
            then
                echo "Instance state is $describeFreshAsg, deployment group creation will now begin"
                #inst ready, create dsg for asg
                deploymentGroupNameFresh=demo-jenkins-dg-fresh
                createDg=$(aws deploy create-deployment-group --application-name $deploymentApplication --auto-scaling-groups $asgNameFresh --deployment-config-name CodeDeployDefault.AllAtOnce --deployment-group-name  $deploymentGroupNameFresh --service-role-arn arn:aws:iam::614083026494:role/TicketingCodedeployToDev --region $awsRegion)
                sleep 10
                echo "Deployment group created, deployment will now begin"
                #deploy to fresh instance
                dp_id=$(aws deploy create-deployment --application-name "$deploymentApplication" --deployment-group-name $deploymentGroupNameFresh --region $awsRegion --s3-location  bucket=$artifactBucketName,bundleType=zip,key=$KEY  | grep deploymentId | tr -d \ \"\,| sed 's/.*://g')
                echo "Deployment created : $dp_id "
                sleep 5
                echo 'getting deployment status'
                dp_id_resp=$(aws deploy get-deployment --deployment-id $dp_id --region $awsRegion | grep status | tr -d \ \"\,| sed 's/.*://g')
                echo $dp_id_resp
                
                var=0
                while true
                do dp_id_resp=$(aws deploy get-deployment --deployment-id $dp_id --region $awsRegion | grep status | tr -d \ \"\,| sed 's/.*://g')
                    var=$((var+1))
                    
                    if [ $var == 61 ]
                    then
                        echo "deployment failed within 30 minutes"
                        exit 1
                    fi
                    
                    if [ $dp_id_resp == "Succeeded" ]
                    then
                        echo "deployment successful, exited"
                        exit 0
                    elif [ $dp_id_resp == "Failed" ] 
                    then    
                        echo "deployment failed, exited"
                        exit 1
                    elif [ $dp_id_resp == "Stopped" ] 
                    then
                        echo "deployment stopped"
                        exit 1
                    else
                        echo "Checking deployment status, please wait."
                            sleep 30
                    fi
                done
                
            else
                echo "Instance state is $describeFreshAsg , waiting for instance to come up."
                sleep 30
            fi
        done
    fi
#ecs deployment
elif [ $deploymentMode == "cloud-native" ]
then
    #create service
    echo "Updating task definition"
    aws ecs register-task-definition --family demo-jenkins --cli-input-json file://build_scripts/taskdefinition.json --region $awsRegion
    #echo "Creating service"
    createServiceResp=$(aws ecs create-service --cluster $clusterName --service-name $serviceName --task-definition $taskDefinition --desired-count 1 --launch-type EC2 --region $awsRegion)
    echo $createServiceResp

else
    echo "Wrong deployment mode selcted"
fi

