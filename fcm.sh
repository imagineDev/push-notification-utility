# Utility to get FCM OAuth Access Token
# Make sure you have valid service-account.json in the same directory.
# Made by Sahil Sharma
# Version 1 - 17th March 2026

#!/bin/bash

SERVICE_ACCOUNT="service-account.json"

CLIENT_EMAIL=$(jq -r .client_email $SERVICE_ACCOUNT)
PRIVATE_KEY=$(jq -r .private_key $SERVICE_ACCOUNT | sed 's/\\n/\n/g')

echo "Working on it ..."

NOW=$(date +%s)
EXP=$(($NOW + 3600))

HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

PAYLOAD=$(echo -n "{
\"iss\":\"$CLIENT_EMAIL\",
\"scope\":\"https://www.googleapis.com/auth/firebase.messaging\",
\"aud\":\"https://oauth2.googleapis.com/token\",
\"exp\":$EXP,
\"iat\":$NOW
}" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

JWT="$HEADER.$PAYLOAD"

SIGNATURE=$(echo -n $JWT | openssl dgst -sha256 -sign <(echo -e "$PRIVATE_KEY") | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

SIGNED_JWT="$JWT.$SIGNATURE"

ACCESS_TOKEN=$(curl -s https://oauth2.googleapis.com/token \
  -d grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
  -d assertion=$SIGNED_JWT | jq -r .access_token)

echo "Access Token: $ACCESS_TOKEN"

echo "$ACCESS_TOKEN" | pbcopy
echo 
echo "Copied to Clipboard!"
