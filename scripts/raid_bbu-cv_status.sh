#!/bin/bash
STORCLI="sudo /opt/MegaRAID/storcli/storcli64"
CONTROLLER="${1:-0}"

# Check for CacheVault
CV_JSON=$($STORCLI "/c${CONTROLLER}/cv" show J 2>/dev/null)

if [ $? -eq 0 ] && [ "$(echo "$CV_JSON" | jq '.["Controllers"][0]["Response Data"].Cachevault_Info[0]')" != "null" ]; then
    echo "$CV_JSON" | jq -c '
      .["Controllers"][0]["Response Data"].Cachevault_Info[0] |
      {
        "type": "CacheVault",
        "model": .Model,
        "status": .State,
        "temperature": (.Temp | gsub("C"; "") | tonumber? // 0),
        "manufacture_date": .MfgDate
      }
    '
    exit 0
fi

# If CacheVault not found, check for BBU
BBU_JSON=$($STORCLI "/c${CONTROLLER}/bbu" show J 2>/dev/null)
if [ $? -eq 0 ] && [ "$(echo "$BBU_JSON" | jq '.["Controllers"][0]["Response Data"]')" != "null" ]; then
    echo "$BBU_JSON" | jq -c '
      .["Controllers"][0]["Response Data"] |
      {
        "type": "BBU",
        "status": (.Status // "Unknown"),
        "temperature": (.Temperature // 0),
        "remaining_percent": ((.GasGauge."Remaining Capacity" // ."Remaining Capacity" // 0) | tonumber? // 0),
        "need_replace": ((.GasGauge."Need Replace" // "No") | test("Yes|True|1"; "i"))
      }
    '
    exit 0
fi

# If nothing found
echo '{"type": "none", "status": "Not Present"}'
