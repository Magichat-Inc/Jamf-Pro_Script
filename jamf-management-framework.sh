#!/bin/bash

# server connection information
jss_url="https://example.jamfcloud.com"
api_user="Username_Here"
api_pw="Userpassword_Here"

# computer_id will have all the affected Macs ID that needs to send this command via API. PLease include with the bracket like above separate with comma
#computer_id="{n,n,n}"
# Single Target
computer_id=n

# Create a Basic_token with base64 encoded
basic_token=$(printf $api_user:$api_pw | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

# Create a API_token based on Basic_token
api_token=$(curl -s -X POST "$jss_url/api/v1/auth/token" -H "accept: application/json" -H "Authorization: Basic $basic_token" | grep 'token' | sed -r 's/^[^:]*:(.*)$/\1/' | tr -d "\",")

# redeploy jamf-management-framework
curl -X POST \
--url "$jss_url/api/v1/jamf-management-framework/redeploy/$computer_id" \
--header "accept: application/json" \
--header "Authorization: Bearer $api_token"

# expire the auth token
curl "$jss_URL/uapi/auth/invalidateToken" \
--silent \
--request POST \
--header "Authorization: Bearer $api_token"

exit 0