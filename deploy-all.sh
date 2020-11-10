#!/bin/bash
BUILD_NUMBER=`git rev-list --all|wc -l|xargs`

#printf "What would you like to build?\n"
#select platform in "Android App Bundle" "Android APK" "iOS"; do
#  echo "Preparing build #$BUILD_NUMBER"
#  case $platform in
#      "Android App Bundle" ) flutter build appbundle --build-number $BUILD_NUMBER; break;;
#      "Android APK" ) flutter build apk --build-number $BUILD_NUMBER; break;;
#      "iOS" ) flutter build ios --build-number $BUILD_NUMBER; break;;
#  esac
#done

flutter clean;
#flutter build appbundle --build-number $BUILD_NUMBER
flutter build ios --build-number $BUILD_NUMBER;
cd ios
fastlane internal --verbose
cd ..

