#!/bin/bash

source $1
device=$2

#Setting the delimiter to newline to prevent the arguments from being split on the space
IFS=$'\n'
IN=`cat $1`
arrIN=(${IN//;/ })
args=""
for i in ${arrIN[@]}
do
    echo $i
    if [[ $i == "dart_"* ]]; then
        args+="--dart-define;"`echo $i | sed -e 's|dart_||'`";"
    fi
done
echo "Using arguments $args"

#Setting the delimiter to semi-colon means we can use spaces in the build arguments
IFS=';'

flutter drive --driver=test_drivers/screenshot_test_driver.dart --target=tests/widget_test.dart -d $device $args

