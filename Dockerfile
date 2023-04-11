#FROM alpine:latest
FROM ubuntu:latest

# The TMOD Version. Ensure that you follow the correct format. Version releases can be found at https://github.com/tModLoader/tModLoader/releases if you're lost.
ARG TMOD_VERSION=v2022.09.47.46

# The shutdown message is broadcast to the game chat when the container was stopped from the host.
ENV TMOD_SHUTDOWN_MESSAGE="Server is shutting down NOW!"

# The autosave feature will save the world periodically. The interval is in minutes.
ENV TMOD_AUTOSAVE_INTERVAL="10"

# Mods which should be downloaded from Steam upon starting the server.
# Example format: 2824688072,2824688266,2835214226
ENV TMOD_AUTODOWNLOAD=""

# The mods we want to enable on the server on startup. Any omitted mods will not be loaded.
# Example format: 2824688072,2824688266,2835214226
ENV TMOD_ENABLEDMODS=""

# If you want to specify your own config, set the following to "Yes".
ENV TMOD_USECONFIGFILE="No"

#--------- CONFIG SECTION --------- #
# The following environment variables will configure common settings for the tModLoader server.

# motd
ENV TMOD_MOTD="A tModLoader server powered by Docker!"
# password
ENV TMOD_PASS="docker"
# maxplayers
ENV TMOD_MAXPLAYERS="8"
# worldname
ENV TMOD_WORLDNAME="Docker"
# autocreate
ENV TMOD_WORLDSIZE="3"
# seed
ENV TMOD_WORLDSEED="Docker"
# difficulty
ENV TMOD_DIFFICULTY="1"
# secure
ENV TMOD_SECURE="0"
# language
ENV TMOD_LANGUAGE="en-US"
# npcstream
ENV TMOD_NPCSTREAM="60"
# upnp
ENV TMOD_UPNP="0"
# priority
ENV TMOD_PRIORITY="1"

# JOURNEY MODE POWER PERMISSIONS

# journeypermission_time_setfrozen
ENV TMOD_JOURNEY_SETFROZEN="0"
# journeypermission_time_setdawn
ENV TMOD_JOURNEY_SETDAWN="0"
# journeypermission_time_setnoon
ENV TMOD_JOURNEY_SETNOON="0"
# journeypermission_time_setdusk
ENV TMOD_JOURNEY_SETDUSK="0"
# journeypermission_time_setmidnight
ENV TMOD_JOURNEY_SETMIDNIGHT="0"
# journeypermission_godmode
ENV TMOD_JOURNEY_GODMODE="0"
# journeypermission_wind_setstrength
ENV TMOD_JOURNEY_WIND_STRENGTH="0"
# journeypermission_rain_setstrength
ENV TMOD_JOURNEY_RAIN_STRENGTH="0"
# journeypermission_time_setspeed
ENV TMOD_JOURNEY_TIME_SPEED="0"
# journeypermission_rain_setfrozen
ENV TMOD_JOURNEY_RAIN_FROZEN="0"
# journeypermission_wind_setfrozen
ENV TMOD_JOURNEY_WIND_FROZEN="0"
# journeypermission_increaseplacementrange
ENV TMOD_JOURNEY_PLACEMENT_RANGE="0"
# journeypermission_setdifficulty
ENV TMOD_JOURNEY_SET_DIFFICULTY="0"
# journeypermission_biomespread_setfrozen
ENV TMOD_JOURNEY_BIOME_SPREAD="0"
# journeypermission_setspawnrate
ENV TMOD_JOURNEY_SPAWN_RATE="0"

# [!!!] The section for using a config file has been deprecated in favor of the environment variable approach.
# Loading a configuration file expects a proper Terraria config file to be mapped to /root/terraria-server/serverconfig.txt
# Set this to "Yes" if you would rather use a config file instead of the above settings.
# ENV TMOD_USECONFIGFILE="No"

EXPOSE 7777

RUN apt-get update
RUN apt-get install -y wget unzip tmux bash lib32gcc-s1 libsdl2-2.0-0

RUN mkdir -p /root/.steam/sdk64
RUN ln -s /root/.steam/steamcmd/linux64/steamclient.so /root/.steam/sdk64/steamclient.so

WORKDIR /root/terraria-server

RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
RUN tar -xvzf steamcmd_linux.tar.gz

RUN /root/terraria-server/steamcmd.sh +force_install_dir /root/terraria-server/workshop-mods +login anonymous +quit
	
RUN wget https://github.com/tModLoader/tModLoader/releases/download/${TMOD_VERSION}/tModLoader.zip 
RUN unzip -o tModLoader.zip 
RUN rm tModLoader.zip 

COPY DotNetInstall.sh ./LaunchUtils
RUN chmod u+x LaunchUtils/DotNetInstall.sh
RUN ./LaunchUtils/DotNetInstall.sh

RUN chmod u+x ./start-tModLoaderServer.sh
RUN chmod u+x LaunchUtils/ScriptCaller.sh

RUN mkdir -p /root/.local/share/Terraria/tModLoader/Worlds 
RUN mkdir /root/.local/share/Terraria/tModLoader/Mods

COPY entrypoint.sh .
COPY inject.sh /usr/local/bin/inject
COPY autosave.sh .
COPY prepare-config.sh .

RUN chmod +x entrypoint.sh /usr/local/bin/inject autosave.sh prepare-config.sh

ENTRYPOINT ["./entrypoint.sh"]