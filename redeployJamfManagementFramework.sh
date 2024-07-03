#!/bin/bash

# Server connection information
jss_url="https://example.jamfcloud.com"
api_user="Username_Here"
api_pw="Userpassword_Here"

# computer_id will have all the affected Macs ID that needs to send this command via API.
# Please include with the bracket like below separate with comma
# computer_id="{n,n,n}"
# Single Target
computer_id=n

# Create a Basic token with base64 encoded
basic_token=$(printf $api_user:$api_pw | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

# Create an API token based on Basic token
api_token=$(curl -s -X POST "$jss_url/api/v1/auth/token" -H "accept: application/json" -H "Authorization: Basic $basic_token" | grep 'token' | sed -r 's/^[^:]*:(.*)$/\1/' | tr -d "\",")

# Redeploy Jamf Management Framework
curl -X POST \
--url "$jss_url/api/v1/jamf-management-framework/redeploy/$computer_id" \
--header "accept: application/json" \
--header "Authorization: Bearer $api_token"

# Invalidate token
curl "$jss_URL/uapi/auth/invalidateToken" \
--silent \
--request POST \
--header "Authorization: Bearer $api_token"

exit 0
