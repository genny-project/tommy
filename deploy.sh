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
versionName=$2
versionCode=$3
appId=`cat ./android/app/build.gradle | grep "applicationId" -m 1 | sed 's/.*applicationId //' | tr -d '"'`
fileDir=`readlink -e $1`
dir=`dirname $fileDir`
projectName=`basename $1`
projectName="${projectName%.*}"
cd android
cp $dir/$projectName/$GOOGLE_PLAY_FILE ./google_play.json
cp $dir/$projectName/$KEY_PROPERTIES ./key.properties
cp $dir/$projectName/$RELEASE_KEYSTORE ./app/`basename $RELEASE_KEYSTORE`
echo "json_key_file(\"google_play.json\")" > ./fastlane/Appfile
echo "package_name(\"$appId\")" >> ./fastlane/Appfile
set_line "version: " "version: $versionName+$versionCode" ../pubspec.yaml
bundle exec fastlane beta file:$dir/`basename $1`


# cd ../ios/

# set_line "DEVELOPMENT_TEAM = " "DEVELOPMENT_TEAM = $DEVELOPMENT_TEAM" ./Runner.xcodeproj/project.pbxproj
# set_line "PROVISIONING_PROFILE_SPECIFIER = " "PROVISIONING_PROFILE_SPECIFIER = $dart_APP_NAME" ./Runner.xcodeproj/project.pbxproj

# echo "app_identifier(\"$appId\")" > ./fastlane/Appfile
# echo "apple_id(\"$APPLE_ID_TO_RELEASE\")" >> ./fastlane/Appfile
# echo "itc_team_id(\"$APPLE_APP_STORE_CONNECT_TEAM_ID\")" >> ./fastlane/Appfile
# echo "team_id(\"$DEVELOPMENT_TEAM\")" >> ./fastlane/Appfile

# bundle exec fastlane beta file:$1

# git restore .