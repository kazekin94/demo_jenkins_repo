#!bin/bash
source $WORKSPACE/build_scripts/config.txt

uniqueName=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c${5:-30})
echo $uniqueName
if [ ! -d "$WORKSPACE/zipArchive" ]; then
    mkdir zipArchive
fi
#sudo cp -R $WORKSPACE/build_scripts $WORKSPACE/appspec.yml $WORKSPACE/zipArchive
filename="${uniqueName}-artifact.zip" >> filename.txt

zip -r $filename build_scripts/* appspec.yml build_scripts/config.txt

echo 'copy artifacts'
echo $filename

aws s3 cp $filename s3://$artifactBucketName
sleep 30

