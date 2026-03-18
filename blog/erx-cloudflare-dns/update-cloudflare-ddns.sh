#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

# --- USER CONFIG ---
CF_API_TOKEN="<your_api_token>"
WAN_IF="eth0"                      # WAN interface with your public IPv4
CF_TTL=120                         # TTL in seconds
CACHE_FILE="/config/scripts/cloudflare-ddns-ip.cache"

# One entry per record:
# "ZONE_ID,RECORD_ID,NAME,TYPE,PROXIED"
# TYPE is usually A (IPv4) or AAAA (IPv6)
# PROXIED is true or false
RECORDS=(
  "<your_zone_id>,<your_record_id>,<your_record_name>,A,false"
)
# -------------------

# Get current IPv4 from WAN interface
current_ip=$(ip -4 addr show "$WAN_IF" | awk '/inet / {print $2}' | cut -d/ -f1)
[ -z "$current_ip" ] && exit 0

# Compare with cached value
if [ -f "$CACHE_FILE" ]; then
    cached_ip=$(cat "$CACHE_FILE")
else
    cached_ip=""
fi

# If unchanged, nothing to do
if [ "$current_ip" = "$cached_ip" ]; then
    exit 0
fi

# Update all records
all_ok=1
for rec in "${RECORDS[@]}"; do
    IFS=',' read -r zone_id rec_id rec_name rec_type rec_proxied <<< "$rec"

    # Only handle IPv4 A records here
    if [[ "$rec_type" != "A" ]]; then
        continue
    fi

    update_response=$(curl -s -X PUT \
      "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$rec_id" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"$rec_type\",\"name\":\"$rec_name\",\"content\":\"$current_ip\",\"ttl\":$CF_TTL,\"proxied\":$rec_proxied}")

    if ! echo "$update_response" | grep -q '"success":true'; then
        all_ok=0
    fi
done

# Only write cache if all updates succeeded
if [ "$all_ok" -eq 1 ]; then
    echo "$current_ip" > "$CACHE_FILE"
fi