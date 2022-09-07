#!/bin/bash

# pre-requirements for running this code:
# 1. put all product related files into a folder with the name of your project and then put that folder into the products folder under root directory
# 2. set up the iOS release certificate on your machine for the project
# 3. make sure the content of YOUR_PROJECT_key.properties matches YOUR_PROJECT_release_key.keystore


product=$1;
echo "Build for Product: $product"

if [[ `git status --porcelain` ]]
then
  echo "Warning: please commit all your files at first. Otherwise, your changes will be lost for sure."
else
    if [ -z "$product" ]
    then
        echo "No project found! Please check your input, e.g, sh build-product.sh internmatch"
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
                )
                for i in "${filesToBeUpdated[@]}"
                do
                    echo "Updating $i"
                    perl -pi -e 's/life.genny.tommy/'$bundleId'/g' $i
                done
                # to search and replace all files in the project, uncomment the following line
                # perl -pi -e 's/life.genny.tommy/'$bundleId'/g' $(git ls-files -- . ':!:*test-product.sh')
                
                echo "Fix appAuthRedirectScheme"
                perl -pi -e 's/'$bundleId'.appauth/life.genny.tommy.appauth/g' android/app/build.gradle

                echo "Move MainActivity.kt to the right package in /android/app/src/main/kotlin"
                mkdir -p android/app/src/main/kotlin/${arrayDirectoryName[0]}/${arrayDirectoryName[1]}/${arrayDirectoryName[2]}
                mv android/app/src/main/kotlin/life/genny/tommy/MainActivity.kt android/app/src/main/kotlin/${arrayDirectoryName[0]}/${arrayDirectoryName[1]}/${arrayDirectoryName[2]}/

                echo "Replace app name"
                perl -pi -e 's/android:label=\"tommy\"/android:label="'$appName'"/g' android/app/src/main/AndroidManifest.xml
                perl -pi -e 's/Tommy/'$appName'/g' ios/Runner/info.plist
                perl -pi -e 's/tommy/'$appName'/g' ios/Runner/info.plist
                perl -pi -e 's/TOMMY/'$appName'/g' lib/pages/login.dart

                echo "Prepare credentials for Google Play Store"
                echo "Put google_play.json in android folder"
                cp products/$product/${product}_google_play.json android/${product}_google_play.json
                perl -pi -e 's/google_play.json/'${product}_google_play.json'/g' android/fastlane/Appfile
                
                echo "Put key.property in android folder"
                cp products/$product/${product}_key.properties android/${product}_key.properties
                perl -pi -e 's/key.properties/'${product}_key.properties'/g' android/app/build.gradle

                echo "Put release-key.keystore in android/app folder"
                cp products/$product/${product}_release_key.keystore android/app/${product}_krelease_key.keystore

                echo "Prepare credentials for Apple App Store "
                perl -pi -e 's/7W5L2XPVKS/'$developmentTeamId'/g' ios/Runner.xcodeproj/project.pbxproj
                perl -pi -e 's/Tommy/'$provisioningProfileSpecifier'/g' ios/Runner.xcodeproj/project.pbxproj
                sed -i '' 's/YOUR_APPLE_ID/'$appleIdToRelease'/' ios/fastlane/Appfile
                perl -pi -e 's/YOUR_APPLE_APP_STORE_CONNECT_TEAM_ID/'$appleAppStoreConnectTeamID'/g' ios/fastlane/Appfile
                
                echo "Publish the App to Google Play Store Internal Testing"
                cd android
                bundle exec fastlane beta
                cd ..

                echo "Publish the App to Apple App TestFlight"
                cd ios
                bundle exec fastlane beta
                cd ..

                echo "Remove all changes in local directory ..."
                git restore .

                echo "All Done!!"
            fi
        fi
    fi
fi



