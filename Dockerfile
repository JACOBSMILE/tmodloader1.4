#FROM alpine:latest
FROM ubuntu:latest

# The TMOD Version. Ensure that you follow the correct format. Version releases can be found at https://github.com/tModLoader/tModLoader/releases if you're lost.
ARG TMOD_VERSION=v2022.09.47.24

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

# Loading a configuration file expects a proper Terraria config file to be mapped to /root/terraria-server/serverconfig.txt
# Set this to "Yes" if you would rather use a config file instead of the above settings.
ENV TMOD_USECONFIGFILE="No"

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

RUN chmod +x entrypoint.sh /usr/local/bin/inject autosave.sh

ENTRYPOINT ["./entrypoint.sh"]