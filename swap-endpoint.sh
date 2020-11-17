#!/bin/bash
LNK=$1
URL='static var url = "https://internmatch-'$LNK'.gada.io";'
sed -i "" "2s~.*~$URL~" lib/ProjectEnv.dart
