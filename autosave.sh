#!/bin/bash

source fixlang.sh

while true
do
    sleep ${TMOD_AUTOSAVE_INTERVAL}m
    echo "[SYSTEM] Saving world..."
    inject "$CMD_SAVE"
    if [ -n "$TMOD_SHUTDOWN_MESSAGE" ]; then
        inject "$CMD_SAY $TMOD_SHUTDOWN_MESSAGE"
    fi
done