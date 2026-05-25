#!/bin/sh

# So server doesn't always save at start if no players are on.
last_players_online=": No players connected."

while true
do
    sleep ${TMOD_AUTOSAVE_INTERVAL}m

    # Poll for output because tmux capture-pane can miss it.
    inject "playing"
    current_players_online=""
    while ! echo "$current_players_online" | grep -q " connected."
    do
    	current_players_online=$(tmux capture-pane -p | tail -n 2)
    	sleep 0.01
    done

    # Check if any players are online before saving.
    if [ "$current_players_online" != ": No players connected." ] || [ "$last_players_online" != ": No players connected." ]; then
        echo "[SYSTEM] Saving world..."
        inject "save"
        inject "say The World has been saved."
        
        # This is necessary to ensure the world is saved once all players log off.
        last_players_online=$current_players_online

    else
        echo "Not saving world."

    fi
done