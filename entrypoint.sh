#!/bin/bash
pipe=/tmp/tmod.pipe

# Check Config
if [[ "$TMOD_USECONFIGFILE" == "Yes" ]]; then
  if [ -e /root/terraria-server/serverconfig.txt ]; then
    echo -e "tModLoader server will launch with the supplied config file."
  else
    echo -e "[!!] ERROR: The tModLoader server was set to launch with a config file, but it was not found. Please map the file and launch the server again."
    sleep 5s
    exit 1
  fi
else
# Print Env variables
  echo -e "Shutdown Message set to: $TMOD_SHUTDOWN_MESSAGE"
  echo -e "Save Interval set to: $TMOD_AUTOSAVE_INTERVAL minutes"
  echo -e "World Name set to: $TMOD_WORLDNAME"
  echo -e "World Size set to: $TMOD_WORLDSIZE"
  echo -e "World Seed set to: $TMOD_WORLDSEED"
  echo -e "Max Players set to: $TMOD_MAXPLAYERS"
  echo -e "Server Password set to: $TMOD_PASS"
  echo -e "MOTD Set to: $TMOD_MOTD"
fi

# Trapped Shutdown, to cleanly shutdown
function shutdown () {
  inject "say $TMOD_SHUTDOWN_MESSAGE"
  sleep 3s
  inject "exit"
  tmuxPid=$(pgrep tmux)
  tmodPid=$(pgrep --parent $tmuxPid Main)
  while [ -e /proc/$tmodPid ]; do
    sleep .5
  done
  rm $pipe
}

# Download Mods
if test -z "${TMOD_AUTODOWNLOAD}" ; then
    echo -e ""
    echo -e " [*] No mods to download. If you wish to download mods at runtime, please set the TMOD_AUTODOWNLOAD environment variable equal to a comma separated list of Mod Workshop IDs."
    echo -e "For  more information, please see the Github README.\n\n"
    sleep 5s
else
    echo -e " [*] Downloading Mods specified in the TMOD_AUTODOWNLOAD Environment Variable. This may hand a while depending on the number of mods..."
    # Convert the Comma Separated list of Mod IDs to a list of SteamCMD commands and call SteamCMD to download them all.
    /root/terraria-server/steamcmd.sh +force_install_dir /root/terraria-server/workshop-mods +login anonymous +workshop_download_item 1281930 `echo -e $TMOD_AUTODOWNLOAD | sed 's/,/ +workshop_download_item 1281930 /g'` +quit
    echo -e " [*] Finished downloading mods.\n\n"
fi

# Enable Mods
enabledpath=/root/.local/share/Terraria/tModLoader/Mods/enabled.json
modpath=/root/terraria-server/workshop-mods/steamapps/workshop/content/1281930
rm -f $enabledpath

if test -z "${TMOD_ENABLEDMODS}" ; then
    echo -e ""
    echo -e " [*] No mods to load. Please set the TMOD_ENABLEDMODS environment variable equal to a comma separated list of Mod Workshop IDs."
    echo -e " For  more information, please see the Github README.\n\n"
    sleep 5s
else
  echo -e " [*] Enabling Mods specified in the TMOD_ENABLEDMODS Environment variable..."
  echo '[' >> $enabledpath
  # Convert the Comma separated list of Mod IDs to an iterable list. We use this to drill through the directories and get the internal names of the mods.
  echo -e $TMOD_ENABLEDMODS | tr "," "\n" | while read LINE
  do
    echo -e ""
    echo -e " [*] Enabling $LINE..."

    if [ $? -ne 0 ]; then
      echo -e " [!!] Mod ID $LINE not found! Has it been downloaded?"
      continue
    fi
    modname=$(ls -1 $(ls -d $modpath/$LINE/*/|tail -n 1) | sed -e 's/\.tmod$//')
    if [ $? -ne 0 ]; then
      echo -e " [!!] An error occurred while attempting to load $LINE."
      continue
    fi
    # For each mod name that we resolve, write the internal name of it to the enabled.json file.
    echo "\"$modname\"," >> $enabledpath
    echo -e " [*] Enabled $modname ($LINE) "
  done
    echo ']' >> $enabledpath
    echo " [*] Finished loading mods."
fi

# Base startup command
server="/root/terraria-server/LaunchUtils/ScriptCaller.sh -server -steamworkshopfolder \"/root/terraria-server/workshop-mods/steamapps/workshop\""

# If config, we supply it at the command line.
if [[ "$TMOD_USECONFIGFILE" == "Yes" ]]; then
  server="$server -config /root/terraria-server/serverconfig.txt"

else
  # Check if the world file exists.
  if [ -e "/root/.local/share/Terraria/tModLoader/Worlds/$TMOD_WORLDNAME.wld" ]; then
    server="$server -world \"/root/.local/share/Terraria/tModLoader/Worlds/$TMOD_WORLDNAME.wld\""
  else
  # If it does not, alert the player, and set the startup parameters to automatically generate the world.
    echo -e "[!!] WARNING: The world \"$TMOD_WORLDNAME\" was not found. The server will automatically create a new world."
    sleep 3s
    server="$server -world \"/root/.local/share/Terraria/tModLoader/Worlds/$TMOD_WORLDNAME.wld\""
    server="$server -autocreate $TMOD_WORLDSIZE -worldname \"$TMOD_WORLDNAME\" -seed \"$TMOD_WORLDSEED\""
  fi

  server="$server -players $TMOD_MAXPLAYERS"

  if [[ "$TMOD_PASS" == "N/A" ]]; then
    echo -e "[!!] Server Password has been disabled."
  else
    server="$server -pass \"$TMOD_PASS\""
  fi

  server="$server -motd \"$TMOD_MOTD\""
fi

# Trap the shutdown
trap shutdown TERM INT
echo -e "tModLoader is launching with the following command:"
echo -e $server

# Create the tmux and pipe, so we can inject commands from 'docker exec [container id] inject [command]' on the host
sleep 5s
mkfifo $pipe
tmux new-session -d "$server | tee $pipe"

# Call the autosaver
/root/terraria-server/autosave.sh &

# Infinitely print the contents of the pipe, so the container still logs the Terraria Server.
cat $pipe &
wait ${!}
