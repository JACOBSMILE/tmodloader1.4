#!/bin/bash
pipe=/tmp/tmod.pipe

mkdir $WORLDSPATH
mkdir $MODSPATH
tModLoader_ID=1281930
internalModsPathPrefix=$HOME/mods
internalModsFullPath=$internalModsPathPrefix/steamapps/workshop
mkdir -p $internalModsFullPath/content
ln -s -T $MODSPATH $internalModsFullPath/content/$tModLoader_ID

if [[ "$UPDATE_NOTICE" != "false" ]]; then
  echo -e "\n\n!!-------------------------------------------------------------------!!"
  echo -e "REGARDING ISSUE #12"
  echo -e "[UPDATE NOTICE] Recently, this container has been updated to remove dependency on the Root User account inside the container."
  echo -e "[UPDATE NOTICE] Because of this update, prior configurations which mapped HOST directories for Mods, Worlds and Custom Configs will no longer work."
  echo -e "[UPDATE NOTICE] Your World files are NOT DELETED!"
  echo -e "[UPDATE NOTICE] If you are experiencing issues with your worlds or mods loading properly, please refer to the following SFB for more information."
  echo -e "[UPDATE NOTICE] https://github.com/JACOBSMILE/tmodloader1.4/wiki/SFB:-Removing-Dependency-on-Root-(Issue-12)"
  echo -e "!!-------------------------------------------------------------------!!"
  echo -e "\n[SYSTEM] The Server will launch in 30 seconds. To disable this notice, set the UPDATE_NOTICE environment variable equal to \"false\"."
  echo -e "[SYSTEM] This notice will be eventually removed in a later update."
  sleep 30s
fi

echo -e "[SYSTEM] Shutdown Message set to: $TMOD_SHUTDOWN_MESSAGE"
echo -e "[SYSTEM] Save Interval set to: $TMOD_AUTOSAVE_INTERVAL minutes"

CONFIGPATH=$DATAPATH/server_config.txt

# Check Config
if [[ "$TMOD_USECONFIGFILE" == "Yes" ]]; then
    if [ -e $CONFIGPATH ]; then
        echo -e "[!!] The tModLoader server was set to load with a config file. It will be used instead of the environment variables."
    else
        echo -e "[!!] FATAL: The tModLoader server was set to launch with a config file, but it was not found. Please map the file to $CONFIGPATH and launch the server again."
        sleep 5s
        exit 1
    fi
else
  ./prepare-config.sh
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
    echo -e "[SYSTEM] No mods to download. If you wish to download mods at runtime, please set the TMOD_AUTODOWNLOAD environment variable equal to a comma separated list of Mod Workshop IDs."
    echo -e "[SYSTEM] For more information, please see the Github README."
    sleep 5s
else
    echo -e "[SYSTEM] Downloading Mods specified in the TMOD_AUTODOWNLOAD Environment Variable. This may hand a while depending on the number of mods..."
    # Convert the Comma Separated list of Mod IDs to a list of SteamCMD commands and call SteamCMD to download them all.
    steamcmd +force_install_dir $internalModsPathPrefix +login anonymous +workshop_download_item 1281930 `echo -e $TMOD_AUTODOWNLOAD | sed 's/,/ +workshop_download_item 1281930 /g'` +quit
    echo -e "[SYSTEM] Finished downloading mods."
fi

# Enable Mods
enabledpath=$DATAPATH/enabled_mods.json

rm -f $enabledpath

if test -z "${TMOD_ENABLEDMODS}" ; then
    echo -e "[SYSTEM] No mods to load. Please set the TMOD_ENABLEDMODS environment variable equal to a comma separated list of Mod Workshop IDs."
    echo -e "[SYSTEM] For more information, please see the Github README."
    sleep 5s
else
  echo -e "[SYSTEM] Enabling Mods specified in the TMOD_ENABLEDMODS Environment variable..."
  echo '[' >> $enabledpath
  # Convert the Comma separated list of Mod IDs to an iterable list. We use this to drill through the directories and get the internal names of the mods.
  echo -e $TMOD_ENABLEDMODS | tr "," "\n" | while read LINE
  do
    echo -e "[SYSTEM] Enabling $LINE..."

    if [ $? -ne 0 ]; then
      echo -e "[!!] Mod ID $LINE not found! Has it been downloaded?"
      continue
    fi
    modname=$(ls -1 $(ls -d $internalModsFullPath/content/$tModLoader_ID/$LINE/*/|tail -n 1) | sed -e 's/\.tmod$//')
    if [ $? -ne 0 ]; then
      echo -e " [!!] An error occurred while attempting to load $LINE."
      continue
    fi
    # For each mod name that we resolve, write the internal name of it to the enabled_mods.json file.
    echo "\"$modname\"," >> $enabledpath
    echo -e "[SYSTEM] Enabled $modname ($LINE) "
  done
    echo ']' >> $enabledpath
    echo "\n[SYSTEM] Finished loading mods."
fi

mkdir -p $HOME/.local/share/Terraria/tModLoader/Mods
ln -s $enabledpath $HOME/.local/share/Terraria/tModLoader/Mods/enabled.json

# Startup command
server="$HOME/LaunchUtils/ScriptCaller.sh -server -steamworkshopfolder \"$internalModsFullPath\" -config \"$CONFIGPATH\""

# Trap the shutdown
trap shutdown TERM INT
echo -e "tModLoader is launching with the following command:"
echo -e $server

# Create the tmux and pipe, so we can inject commands from 'docker exec [container id] inject [command]' on the host
sleep 5s
mkfifo $pipe
tmux new-session -d "$server | tee $pipe"

# Call the autosaver
$HOME/autosave.sh &

# Infinitely print the contents of the pipe, so the container still logs the Terraria Server.
cat $pipe &
wait ${!}