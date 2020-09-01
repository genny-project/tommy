#!/bin/bash
GOOGLE_SERVICES_JSON=$1
sed -i "1s~.*~$GOOGLE_SERVICES_JSON~" ./android/app/google-services.json
