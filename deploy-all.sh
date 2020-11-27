#!/bin/bash
BUILD_NUMBER=`git rev-list --all|wc -l|xargs`
BUILD_NAME=`git branch --show-current`
./swap-endpoint.sh internmatch-mobile.gada.io
flutter clean
flutter build ios --build-name $BUILD_NAME --build-number $BUILD_NUMBER --no-codesign
cd ios
fastlane internal
cd ..
