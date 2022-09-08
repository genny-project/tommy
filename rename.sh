function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function replaceYaml {
    local key=$1
    local value=$2
    echo $key
    echo $value
    sed -i "s|^$key:.*|$key: $value|" pubspec.yaml
}

if [ "$#" -ne 3 ]; then
    echo "Incorrect parameters. [App name, app display name, bundleID]"
    exit
fi

yaml=`parse_yaml ./pubspec.yaml`
arrIN=(${yaml// / })
existing=`echo ${arrIN[0]//name=\"/ } | tr -d '"'`
if [ "$1" == "$existing" ]; then
    echo "App is already named $existing"
    exit
fi
echo "existing $existing"
appId=`cat ./android/app/build.gradle | grep "applicationId" -m 1 | sed 's/.*applicationId //' | tr -d '"'`
echo $appId
existingStrip=`echo $existing | tr -d '"'`
replaceYaml name $1


###Begin changing display name
echo "Changing iOS Display Name"
plist=`cat ./ios/Runner/Info.plist`
IFS=$'\n'
plistArray=(${plist//;/ })
for i in "${!plistArray[@]}"; do
    if [[ ${plistArray[$i]} == *"<key>CFBundleDisplayName</key>" ]]; then
        sed -i "s|${plistArray[$i+1]}|    <string>$2</string>|" ./ios/Runner/Info.plist
    fi
done
unset IFS
###End changing display name

find ./lib/ ./integration_test/ ./test/ -type f -exec sed -i -e "s/package:$existing/package:$1/" {} \;
find ./android ./ios ./lib -type f -exec sed -i -e "s/$appId/$3/" {} \;
sed -i 's|$'\t'<key>CFBundleDisplayName</key>$'\n'$'\t'<string>.*</string>|thingy!!|' ./ios/Runner/Info.plist
#### If this fails, run [flutter pub global activate rename]
flutter pub global run rename --appname $1
flutter pub global run rename --bundleId $3

#### all of this is a bit of a shock to the system, this is to straighten it out
flutter clean
./android/gradlew --stop
