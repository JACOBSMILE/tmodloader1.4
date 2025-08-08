#!/bin/bash

source fixlang.sh

while true
do
    sleep ${TMOD_AUTOSAVE_INTERVAL}m
    echo "[SYSTEM] Saving world..."
    inject "$CMD_SAVE"
    if [ "$TMOD_SEND_AUTOSAVE_MESSAGE" == "1" ]; then
        inject "$CMD_SAY $MSG_SAVE"
    fi
done