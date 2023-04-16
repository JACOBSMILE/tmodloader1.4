FROM steamcmd/steamcmd:ubuntu-22 as builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl tar \
    && apt-get -y autoremove \
    && apt-get autoclean

# Download and unpack steamcmd installer
WORKDIR /root/installer
RUN curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -

FROM ubuntu:latest

# The TMOD Version. Ensure that you follow the correct format. Version releases can be found at https://github.com/tModLoader/tModLoader/releases if you're lost.
ARG TMOD_VERSION=v2022.09.47.47

# Sends update messages to the console before launch.
ENV UPDATE_NOTICE="true"

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

# Copy steamcmd and its required libs from the builder
COPY --chown=0:0 --from=builder /root/installer/steamcmd.sh /usr/lib/games/steam/
COPY --chown=0:0 --from=builder /root/installer/linux32/steamcmd /usr/lib/games/steam/
COPY --chown=0:0 --from=builder /usr/games/steamcmd /usr/bin/steamcmd
COPY --chown=0:0 --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --chown=0:0 --from=builder /lib/i386-linux-gnu /lib/
COPY --chown=0:0 --from=builder /root/installer/linux32/libstdc++.so.6 /lib/

RUN apt-get update \
    && apt-get install -y curl tar wget unzip tmux bash libsdl2-2.0-0 \
    && apt-get -y autoremove \
    && apt-get autoclean

# Create the non-privileged user and its folders, set correct permissions, and drop root
ENV HOME=/terraria-server
RUN groupadd -g 456 terraria \
    && useradd -g terraria -u 456 terraria -d $HOME -m -s /bin/bash

ENV DATAPATH=/data
ENV WORLDSPATH=$DATAPATH/worlds
ENV MODSPATH=$DATAPATH/mods

RUN mkdir $DATAPATH \
    && chown -R terraria:terraria $DATAPATH \
    && chown -R terraria:terraria $HOME

USER terraria

EXPOSE 7777

WORKDIR $HOME

RUN steamcmd +@sSteamCmdForcePlatformType linux $HOME +login anonymous +quit

RUN [ $TMOD_VERSION = "latest" ] && wget https://github.com/tModLoader/tModLoader/releases/latest/download/tModLoader.zip || wget https://github.com/tModLoader/tModLoader/releases/download/${TMOD_VERSION}/tModLoader.zip \
    && unzip -o tModLoader.zip \
    && rm tModLoader.zip

RUN chmod 755 ./start-tModLoaderServer.sh \
    && chmod 755 ./LaunchUtils/ScriptCaller.sh

COPY --chown=0:0 --chmod=755 inject.sh /usr/local/bin/inject
COPY --chown=terraria:terraria --chmod=755 DotNetInstall.sh ./LaunchUtils
COPY --chown=terraria:terraria --chmod=755 entrypoint.sh .
COPY --chown=terraria:terraria --chmod=755 autosave.sh .
COPY --chown=terraria:terraria --chmod=755 prepare-config.sh .

RUN ./LaunchUtils/DotNetInstall.sh

RUN rm -rf $HOME/Libraries/Native/OSX \
    && rm -rf $HOME/Libraries/Native/Windows \
    && rm -rf $HOME/.local/share/Steam/steamcmd/siteserverui \
    && rm -rf $HOME/.local/share/Steam/steamcmd/package

ENTRYPOINT ["./entrypoint.sh"]

VOLUME ["/data"]
