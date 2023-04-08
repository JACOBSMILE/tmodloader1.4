# Builder is ubuntu-based because we need i386 libs
FROM steamcmd/steamcmd:ubuntu-22 as builder

# Install prerequisites to download steamcmd
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl tar
WORKDIR /root/installer

# Download and unpack installer
RUN curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar zxvf -

#####

FROM ubuntu:latest

# Copy steamcmd and its required libs from the builder
COPY --from=builder /root/installer/steamcmd.sh /usr/lib/games/steam/
COPY --from=builder /root/installer/linux32/steamcmd /usr/lib/games/steam/
COPY --from=builder /usr/games/steamcmd /usr/bin/steamcmd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /lib/i386-linux-gnu /lib/
COPY --from=builder /root/installer/linux32/libstdc++.so.6 /lib/
RUN chown -R root:root /usr/bin/ /etc/ssl/certs /lib/ /usr/lib/

RUN apt-get update \
    && apt-get install -y wget unzip tmux bash libsdl2-2.0-0
        
# Create a user and drop root
RUN useradd -ms /bin/bash npc
ENV HOME=/home/npc
USER npc

###

EXPOSE 7777

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

# The following environment variables will configure common settings for the tModLoader server.
ENV TMOD_MOTD="A tModLoader server powered by Docker!"
ENV TMOD_PASS="docker"
ENV TMOD_MAXPLAYERS="8"
ENV TMOD_WORLDNAME="Docker"
ENV TMOD_WORLDSIZE="3"
ENV TMOD_WORLDSEED="Docker"

# Loading a configuration file expects a proper Terraria config file to be mapped to $HOME/terraria-server/serverconfig.txt
# Set this to "Yes" if you would rather use a config file instead of the above settings.
ENV TMOD_USECONFIGFILE="No"

###

WORKDIR $HOME/terraria-server

RUN steamcmd $HOME/terraria-server +login anonymous +quit

RUN wget https://github.com/tModLoader/tModLoader/releases/download/${TMOD_VERSION}/tModLoader.zip 
RUN unzip -o tModLoader.zip \
    && rm tModLoader.zip 

COPY DotNetInstall.sh ./LaunchUtils
COPY entrypoint.sh .
COPY inject.sh /usr/local/bin/inject
COPY autosave.sh .

# Acquire root once more just to set the correct permissions, and drop it again immediately
USER root
RUN chown -R npc:npc /home/npc \
    && chmod u+x ./LaunchUtils/DotNetInstall.sh \
    && chmod u+x ./start-tModLoaderServer.sh \
    && chmod u+x ./LaunchUtils/ScriptCaller.sh \
    && chmod +x entrypoint.sh /usr/local/bin/inject autosave.sh
USER npc

RUN LaunchUtils/DotNetInstall.sh

RUN mkdir -p $HOME/.local/share/Terraria/tModLoader/Worlds \
    && mkdir -p $HOME/.local/share/Terraria/tModLoader/Mods

ENTRYPOINT ["./entrypoint.sh"]