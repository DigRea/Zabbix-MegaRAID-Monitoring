#!/bin/bash
STORCLI="sudo /opt/MegaRAID/storcli/storcli64"
CONTROLLER="${1:-0}"

VD_JSON=$($STORCLI "/c${CONTROLLER}/vall" show J 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$VD_JSON" ]; then
    echo '{"error": "Failed to execute storcli"}'
    exit 1
fi

# Use quotes for keys with spaces
echo "$VD_JSON" | jq -c '
  .["Controllers"][0]["Response Data"]["Virtual Drives"] // [] | 
  map({
    "dg_vd": ."DG/VD",
    "type": .TYPE,
    "state": .State,
    "access": .Access,
    "consist": .Consist,
    "cache": .Cache,
    "size": .Size,
    "name": .Name
  })
'
