#!/bin/bash
BUILD_NUMBER=`git rev-list --all|wc -l|xargs`
BUILD_NAME=`git branch --show-current`
#BUILD_NUMBER="82"
#BUILD_NAME="7.6.0"

#printf "What would you like to build?\n"
#select platform in "Android App Bundle" "Android APK" "iOS"; do
#  echo "Preparing build #$BUILD_NUMBER"
#  case $platform in
#      "Android App Bundle" ) flutter build appbundle --build-number $BUILD_NUMBER; break;;
#      "Android APK" ) flutter build apk --build-number $BUILD_NUMBER; break;;
#      "iOS" ) flutter build ios --build-number $BUILD_NUMBER; break;;
#  esac
#done
./swap-endpoint.sh internmatch-dev.gada.io
flutter clean;
#flutter build appbundle --build-number $BUILD_NUMBER
flutter build ios --build-name $BUILD_NAME --build-number $BUILD_NUMBER
cd ios
fastlane internal --verbose
cd ..
