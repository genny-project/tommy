#!/usr/bin/bash

function set_line {
    local prefix=$1
    local replace=$2
    local file=$3
    fileContent=`cat $file`
    IFS=$'\n'
    array=(${fileContent// / })
    for i in "${array[@]}"; do
        if [[ $i == *"$prefix"* ]]; then
            tag=`echo $i | tr -d '\t'`
            sed -i "s/$tag/$replace/" $file
        fi
    done
    unset IFS
}

source $1
appId=`cat ./android/app/build.gradle | grep "applicationId" -m 1 | sed 's/.*applicationId //' | tr -d '"'`
fileDir=`readlink -e $1`
dir=`dirname $fileDir`
cd android
# cp $dir/$GOOGLE_PLAY_FILE ./google_play.json
# cp $dir/$KEY_PROPERTIES ./key.properties
# cp $dir/$RELEASE_KEYSTORE ./app/release_key.keystore
echo "json_key_file(\"google_play.json\")" > ./fastlane/Appfile
echo "package_name(\"$appId\")" >> ./fastlane/Appfile
bundle exec fastlane beta file:$1


cd ../ios/

set_line "DEVELOPMENT_TEAM = " "DEVELOPMENT_TEAM = $DEVELOPMENT_TEAM" ./Runner.xcodeproj/project.pbxproj
set_line "PROVISIONING_PROFILE_SPECIFIER = " "PROVISIONING_PROFILE_SPECIFIER = $dart_APP_NAME" ./Runner.xcodeproj/project.pbxproj

echo "app_identifier(\"$appId\")" > ./fastlane/Appfile
echo "apple_id(\"$APPLE_ID_TO_RELEASE\")" >> ./fastlane/Appfile
echo "itc_team_id(\"$APPLE_APP_STORE_CONNECT_TEAM_ID\")" >> ./fastlane/Appfile
echo "team_id(\"$DEVELOPMENT_TEAM\")" >> ./fastlane/Appfile

bundle exec fastlane beta file:$1

git restore .