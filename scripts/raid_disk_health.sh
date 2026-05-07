#!/bin/bash
CACHE_FILE="/tmp/raid_disk_health.cache"
CACHE_TTL=240

# Check cache
if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt $CACHE_TTL ]; then
    cat "$CACHE_FILE"
    exit 0
fi

# Update cache
STORCLI="sudo /opt/MegaRAID/storcli/storcli64"
CONTROLLER="${1:-0}"

# Get disk list
DISKS=$($STORCLI "/c${CONTROLLER}/eall/sall" show J 2>/dev/null | jq -r '.["Controllers"][0]["Response Data"]["Drive Information"][] | ."EID:Slt" // empty' 2>/dev/null)

if [ -z "$DISKS" ]; then
    echo '[]' | tee "$CACHE_FILE"
    exit 0
fi

result=""
for disk in $DISKS; do
    EID=$(echo "$disk" | cut -d: -f1)
    SLOT=$(echo "$disk" | cut -d: -f2)
    
    DETAILS=$($STORCLI "/c${CONTROLLER}/e${EID}/s${SLOT}" show all J 2>/dev/null)
    
    # Extract state data using a simpler approach
    health_data=$(echo "$DETAILS" | jq -c \
        --arg eid_slot "$disk" \
        '.["Controllers"][0]["Response Data"] 
        | .[ keys[] | select(endswith("Detailed Information")) ]
        | .[ keys[] | select(endswith("State")) ]
        | {
            "eid_slot": $eid_slot,
            "media_errors": (.["Media Error Count"] // 0),
            "other_errors": (.["Other Error Count"] // 0),
            "predictive_failure_count": (.["Predictive Failure Count"] // 0),
            "smart_alert": (.["S.M.A.R.T alert flagged by drive"] // "No"),
            "temperature": (.["Drive Temperature"] // "0C" | sub("C.*$"; "") | gsub(" "; "") | tonumber? // 0),
            "shield_counter": (.["Shield Counter"] // 0)
        }' 2>/dev/null)
    
    if [ -n "$health_data" ] && [ "$health_data" != "null" ]; then
        if [ -z "$result" ]; then
            result="$health_data"
        else
            result="$result,$health_data"
        fi
    fi
done

if [ -n "$result" ]; then
    echo "[$result]" | tee "$CACHE_FILE"
else
    echo '[]' | tee "$CACHE_FILE"
fi
