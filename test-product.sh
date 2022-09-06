#!/bin/bash

# pre-requirements for running this code:
# 1. put all product related files into a folder with the name of your project and then put that folder into the products folder under root directory
# 2. set up the iOS release certificate on your machine for the project
# 3. make sure the content of YOUR_PROJECT_key.properties matches YOUR_PROJECT_release_key.keystore


product=$1;
device=$2;
echo "Build $product for $device"

if [[ `git status --porcelain` ]]
then
  echo "Warning: please commit all your files at first. Otherwise, your changes will be lost for sure."
else
    if [ -z "$product" ] || [ -z "$device" ]
    then
        echo "No project or device found! Please check your input, e.g, sh test-product.sh internmatch iPhone\ 13"
    else
        appName=`jq '.appName' products/$product/${product}_config.json | tr -d '"'`
        bundleId=`jq '.bundleId' products/$product/${product}_config.json | tr -d '"'`
        grpcUrl=`jq '.grpcUrl' products/$product/${product}_config.json | tr -d '"'`
        grpcPort=`jq '.grpcPort' products/$product/${product}_config.json | tr -d '"'`
        developmentTeamId=`jq '.developmentTeamId' products/$product/${product}_config.json | tr -d '"'`
        provisioningProfileSpecifier=`jq '.provisioningProfileSpecifier' products/$product/${product}_config.json | tr -d '"'`
        appleIdToRelease=`jq '.appleIdToRelease' products/$product/${product}_config.json | tr -d '"'`
        # to get appleAppStoreConnectTeamID, visit https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/detail and look for contentProviderId
        appleAppStoreConnectTeamID=`jq '.appleAppStoreConnectTeamID' products/$product/${product}_config.json | tr -d '"'`

        if [ -z "$appName" ] || [ -z "$bundleId" ] || [ -z "$grpcUrl" ] || [ -z "$grpcPort" ] || [ -z "$developmentTeamId" ] || [ -z "$provisioningProfileSpecifier" ]  || [ -z "$appleIdToRelease" ] || [ -z "$appleAppStoreConnectTeamID" ]
        then
            echo `$product-config.json does not exist.`
        else
            arrayDirectoryName=(${bundleId//./ })
            if [ ${#arrayDirectoryName[@]} != 3 ]
            then
                echo "Bundle id is in wrong format"
            else
                echo "Replace grpcUrl and grpcPort"
                perl -pi -e 's/5154/'$grpcPort'/g' lib/projectenv.dart
                perl -pi -e 's/10.0.2.2/'$grpcUrl'/g' lib/projectenv.dart
                perl -pi -e 's/lojing-dev.gada.io/'$grpcUrl'/g' lib/projectenv.dart

                echo "Replace bundle id and package name"
                filesToBeUpdated=(
                    android/app/build.gradle
                    android/app/src/debug/AndroidManifest.xml
                    android/app/src/main/AndroidManifest.xml
                    android/app/src/main/kotlin/life/genny/tommy/MainActivity.kt
                    android/app/src/profile/AndroidManifest.xml
                    android/fastlane/Appfile
                    ios/fastlane/Appfile
                    ios/Runner.xcodeproj/project.pbxproj
                    lib/pages/login.dart
                )
                for i in "${filesToBeUpdated[@]}"
                do
                    echo "Updating $i"
                    perl -pi -e 's/life.genny.tommy/'$bundleId'/g' $i
                done
                # to search and replace all files in the project, uncomment the following line
                # perl -pi -e 's/life.genny.tommy/'$bundleId'/g' $(git ls-files -- . ':!:*test-product.sh')

                echo "Move MainActivity.kt to the right package in /android/app/src/main/kotlin"
                mkdir -p android/app/src/main/kotlin/${arrayDirectoryName[0]}/${arrayDirectoryName[1]}/${arrayDirectoryName[2]}
                mv android/app/src/main/kotlin/life/genny/tommy/MainActivity.kt android/app/src/main/kotlin/${arrayDirectoryName[0]}/${arrayDirectoryName[1]}/${arrayDirectoryName[2]}/

                echo "Replace app name"
                perl -pi -e 's/android:label=\"tommy\"/android:label="'$appName'"/g' android/app/src/main/AndroidManifest.xml
                perl -pi -e 's/Tommy/'$appName'/g' ios/Runner/info.plist
                perl -pi -e 's/tommy/'$appName'/g' ios/Runner/info.plist

                echo "Launch $product on $device"
                flutter run -d "${device}"

                echo "Remove all changes in local directory ..."
                git restore .

                echo "All Done!!"
            fi
        fi
    fi
fi



