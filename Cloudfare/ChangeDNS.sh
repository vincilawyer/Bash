#!/bin/bash
read -p "$(echo "请填写ip地址：")" IP_ADDRESS
if [[ -z $ip ]]; then
    echo -e "已取消ip设置"
else
    API_ENDPOINT="https://api.cloudflare.com/client/v4/zones"
    CF_EMAIL="user@domain.com"
    CF_API_KEY="key"
    DOMAIN_NAME="domain.com"
    RECORD_NAME="ip"
    
    # Get zone ID for the domain
    ZONE_ID=$(curl -sX GET "$API_ENDPOINT" \
       -H "X-Auth-Email: $CF_EMAIL" \
       -H "X-Auth-Key: $CF_API_KEY" \
       -H "Content-Type: application/json" \
       -d '{"name":"'${DOMAIN_NAME}'"}' \
       | jq -r '{"result"}[] | .[0] | .id')
    # Get record ID for the record name
  RECORD_ID=$(curl -sX GET "$API_ENDPOINT/$ZONE_ID/dns_records" \
       -H "X-Auth-Email: $CF_EMAIL" \
       -H "X-Auth-Key: $CF_API_KEY" \
       -H "Content-Type: application/json" \
       -d '{"name":"'${RECORD_NAME}'.'${DOMAIN_NAME}'","type":"A"}' \
       | jq -r '{"result"}[] | .[0] | .id')
 
  # Update the record with the new IP address
  curl -sX PUT "$API_ENDPOINT/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "X-Auth-Email: $CF_EMAIL" \
     -H "X-Auth-Key: $CF_API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${RECORD_NAME}'.'${DOMAIN_NAME}'","content":"'${IP_ADDRESS}'","ttl":1}'
fi

