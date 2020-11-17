#!/bin/bash
INPUT_URL=$1
VAR_URL='  static var url = "https://'$INPUT_URL'";'
sed -i "" "2s~.*~$VAR_URL~" lib/ProjectEnv.dart
