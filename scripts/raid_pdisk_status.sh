#!/bin/bash
STORCLI="sudo /opt/MegaRAID/storcli/storcli64"
CONTROLLER="${1:-0}"

PD_JSON=$($STORCLI "/c${CONTROLLER}/eall/sall" show J 2>/dev/null)

if [ $? -ne 0 ]; then
    echo '{"error": "Failed to execute storcli"}'
    exit 1
fi

echo "$PD_JSON" | jq -c '
  .["Controllers"][0]["Response Data"]["Drive Information"] // [] | 
  map({
    "eid_slot": ."EID:Slt",
    "state": .State,
    "dg": .DG,
    "size": .Size,
    "interface": .Intf,
    "media": .Med,
    "model": (.Model | gsub("\\s+$"; ""))
  })
'
