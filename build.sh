#!/usr/bin/bash
source $1
device=$2
platform=$3
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
if [ -z "$platform" ]; then 
    flutter run -d $device $args
else
    if [ $platform == "android" ]; then
        flutter build apk $args
    elif [ $platform == "ios" ]; then
        flutter build ipa $args
    fi

fi