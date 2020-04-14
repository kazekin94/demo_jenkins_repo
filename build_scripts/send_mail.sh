#!/bin/sh
source $WORKSPACE/build_scripts/config.txt
#remove echo after testing.
jobStatus=$1

body="Hello User,\n\n"
#attachLog=''
branch='master'
if [ $jobStatus == 'SUCCESS' ]
then
        bucketName=$artifactBucketName
        artifactPath="s3://$bucketName"
        body="$body Branch $branch is successfully build. \n\n"
        body="$body Bucket link - $bucketName/file \n\n"
        body="$body Artifacts path - $artifactPath \n\n"
		#aws cloudfront create-invalidation --distribution-id $distributionId --paths '/*'
elif [ $jobStatus == 'FAILURE' ]
then
    body="$body Branch $branch failed to build. \n\n"
	body="$body Stage failed - $currentStage \n\n"
	#body="$body Build log link - $BUILD_URL \n\n"
elif [ $jobStatus == 'ABORTED' ]
then
        body="$body Branch $branch build was aborted. \n\n"
elif [ $jobStatus == 'UNSTABLE' ]
then
        body="$body Branch $branch build is unstable. \n\n"
else
        body="$body Unable to get branch $branch build status. \n\n"
fi
body="${body}Regards,\nAnkit"


echo '{"Data": "From: '${sesFromEmail}'\nTo: '${toEmails}'\nSubject: Website - Branch Deployment - '${jobStatus}'\nMIME-Version: 1.0\nContent-type: Multipart/Mixed; boundary=\"NextPart\"\n\n--NextPart\nContent-Type: text/plain\n\n'${body}'"}' > $branch.json & aws ses send-raw-email --raw-message file://./$branch.json --region "ap-south-1"
