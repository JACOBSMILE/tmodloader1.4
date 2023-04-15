#!/bin/bash

CONFIGPATH=$DATAPATH/server_config.txt

# Print Env variables
echo -e "[COFNIG] Config File Path: $CONFIGPATH"
echo -e "[CONFIG] Setting Config Values..."
echo -e "[CONFIG] TERRARIA CONFIG SETTINGS"
echo -e "[CONFIG] MOTD Set to: $TMOD_MOTD"
echo -e "[CONFIG] Server Password set to: $TMOD_PASS"
echo -e "[CONFIG] Max Players set to: $TMOD_MAXPLAYERS"
echo -e "[CONFIG] World Name set to: $TMOD_WORLDNAME"
echo -e "[CONFIG] World Size set to: $TMOD_WORLDSIZE"
echo -e "[CONFIG] World Seed set to: $TMOD_WORLDSEED"
echo -e "[CONFIG] Difficulty set to: $TMOD_DIFFICULTY"
echo -e "[CONFIG] Secure Mode set to: $TMOD_SECURE"
echo -e "[CONFIG] Language set to: $TMOD_LANGUAGE"
echo -e "[CONFIG] NPC Stream set to: $TMOD_NPCSTREAM"
echo -e "[CONFIG] UPNP set to: $TMOD_UPNP"
echo -e "[CONFIG] Priority set to: $TMOD_PRIORITY"
echo -e "[CONFIG] JOURNEY MODE SETTINGS"
echo -e "[CONFIG] journeypermission_time_setfrozen: $TMOD_JOURNEY_SETFROZEN"
echo -e "[CONFIG] journeypermission_time_setdawn: $TMOD_JOURNEY_SETDAWN"
echo -e "[CONFIG] journeypermission_time_setnoon: $TMOD_JOURNEY_SETNOON"
echo -e "[CONFIG] journeypermission_time_setdusk: $TMOD_JOURNEY_SETDUSK"
echo -e "[CONFIG] journeypermission_time_setmidnight: $TMOD_JOURNEY_SETMIDNIGHT"
echo -e "[CONFIG] journeypermission_godmode: $TMOD_JOURNEY_GODMODE"
echo -e "[CONFIG] journeypermission_wind_setstrength: $TMOD_JOURNEY_WIND_STRENGTH"
echo -e "[CONFIG] journeypermission_rain_setstrength: $TMOD_JOURNEY_RAIN_STRENGTH"
echo -e "[CONFIG] journeypermission_time_setspeed: $TMOD_JOURNEY_TIME_SPEED"
echo -e "[CONFIG] journeypermission_rain_setfrozen: $TMOD_JOURNEY_RAIN_FROZEN"
echo -e "[CONFIG] journeypermission_wind_setfrozen: $TMOD_JOURNEY_WIND_FROZEN"
echo -e "[CONFIG] journeypermission_increaseplacementrange: $TMOD_JOURNEY_PLACEMENT_RANGE"
echo -e "[CONFIG] journeypermission_setdifficulty: $TMOD_JOURNEY_SET_DIFFICULTY"
echo -e "[CONFIG] journeypermission_biomespread_setfrozen: $TMOD_JOURNEY_BIOME_SPREAD"
echo -e "[CONFIG] journeypermission_setspawnrate: $TMOD_JOURNEY_SPAWN_RATE"

# Check if the world file exists.
if [ -e "$WORLDSPATH/$TMOD_WORLDNAME.wld" ]; then
    echo "world=$WORLDSPATH/$TMOD_WORLDNAME.wld" >> "$CONFIGPATH"
    echo "worldpath=$WORLDSPATH" >> "$CONFIGPATH"
else
# If it does not, alert the player, and set the startup parameters to automatically generate the world.
    echo -e "[!!] WARNING: The world \"$TMOD_WORLDNAME\" was not found. The server will automatically create a new world."
    sleep 3s
    echo "world=$WORLDSPATH/$TMOD_WORLDNAME.wld" >> "$CONFIGPATH"
    echo "worldpath=$WORLDSPATH" >> "$CONFIGPATH"
    echo "worldname=$TMOD_WORLDNAME" >> "$CONFIGPATH"
    echo "autocreate=$TMOD_WORLDSIZE" >> "$CONFIGPATH"
fi

if [[ "$TMOD_PASS" == "N/A" ]]; then
    echo -e "[!!] Server Password has been disabled."
else
    echo "password=$TMOD_PASS" >> "$CONFIGPATH"
fi

echo "motd=$TMOD_MOTD" >> "$CONFIGPATH"
echo "maxplayers=$TMOD_MAXPLAYERS" >> "$CONFIGPATH"
echo "seed=$TMOD_WORLDSEED" >> "$CONFIGPATH"
echo "difficulty=$TMOD_DIFFICULTY" >> "$CONFIGPATH"
echo "secure=$TMOD_SECURE" >> "$CONFIGPATH"
echo "language=$TMOD_LANGUAGE" >> "$CONFIGPATH"
echo "npcstream=$TMOD_NPCSTREAM" >> "$CONFIGPATH"
echo "upnp=$TMOD_UPNP" >> "$CONFIGPATH"
echo "priority=$TMOD_PRIORITY" >> "$CONFIGPATH"

echo "journeypermission_time_setfrozen=$TMOD_JOURNEY_SETFROZEN" >> "$CONFIGPATH"
echo "journeypermission_time_setdawn=$TMOD_JOURNEY_SETDAWN" >> "$CONFIGPATH"
echo "journeypermission_time_setnoon=$TMOD_JOURNEY_SETNOON" >> "$CONFIGPATH"
echo "journeypermission_time_setdusk=$TMOD_JOURNEY_SETDUSK" >> "$CONFIGPATH"
echo "journeypermission_time_setmidnight=$TMOD_JOURNEY_SETMIDNIGHT" >> "$CONFIGPATH"
echo "journeypermission_godmode=$TMOD_JOURNEY_GODMODE" >> "$CONFIGPATH"
echo "journeypermission_wind_setstrength=$TMOD_JOURNEY_WIND_STRENGTH" >> "$CONFIGPATH"
echo "journeypermission_rain_setstrength=$TMOD_JOURNEY_RAIN_STRENGTH" >> "$CONFIGPATH"
echo "journeypermission_time_setspeed=$TMOD_JOURNEY_TIME_SPEED" >> "$CONFIGPATH"
echo "journeypermission_rain_setfrozen=$TMOD_JOURNEY_RAIN_FROZEN" >> "$CONFIGPATH"
echo "journeypermission_wind_setfrozen=$TMOD_JOURNEY_WIND_FROZEN" >> "$CONFIGPATH"
echo "journeypermission_increaseplacementrange=$TMOD_JOURNEY_PLACEMENT_RANGE" >> "$CONFIGPATH"
echo "journeypermission_setdifficulty=$TMOD_JOURNEY_SET_DIFFICULTY" >> "$CONFIGPATH"
echo "journeypermission_biomespread_setfrozen=$TMOD_JOURNEY_BIOME_SPREAD" >> "$CONFIGPATH"
echo "journeypermission_setspawnrate=$TMOD_JOURNEY_SPAWN_RATE" >> "$CONFIGPATH"

echo -e "[CONFIG] Finished setting config settings."