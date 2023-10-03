#!/bin/sh

while true
do
    sleep ${TMOD_AUTOSAVE_INTERVAL}m
    echo "[SYSTEM] Saving world..."
    inject "save"
    inject "say The World has been saved."
done