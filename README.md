# tModLoader Powered By Docker
![Discord](https://img.shields.io/discord/1132368789518950521?logo=discord&label=Discord%20Server&style=for-the-badge)

![Auto-Update Badge](https://img.shields.io/github/actions/workflow/status/jacobsmile/tmodloader1.4/tmodloader-check.yml?logo=github&label=tModLoader%20Auto-Updater&style=for-the-badge)

![Contributors](https://img.shields.io/github/contributors/jacobsmile/tmodloader1.4?logo=github&style=for-the-badge)
![Stars](https://img.shields.io/github/stars/jacobsmile/tmodloader1.4?logo=github&label=github%20stars&style=for-the-badge)
![OpenIssues](https://img.shields.io/github/issues/jacobsmile/tmodloader1.4?logo=github&style=for-the-badge)
![ClosedIssues](https://img.shields.io/github/issues-closed/jacobsmile/tmodloader1.4?logo=github&style=for-the-badge)

![DockerPulls](https://img.shields.io/docker/pulls/jacobsmile/tmodloader1.4?logo=docker&style=for-the-badge)
![DockerStars](https://img.shields.io/docker/stars/jacobsmile/tmodloader1.4?logo=docker&style=for-the-badge)

![Unraid](https://img.shields.io/badge/Available_On_Unraid_Community_Apps!-gray?logo=unraid&link=https%3A%2F%2Funraid.net%2Fcommunity%2Fapps%3Fq%3Dtmodloader%23r&style=for-the-badge)

---
# Important Notices

## Recent changes to Directory Mapping
This container recently updated from requiring separate mapped `world` and `mods` directories to your host for persistence. This has been updated to a common `/data` directory. This README has been updated to reflect this change.

## Upcoming 1.4.4 Update
tModLoader will soon be updating to Terraria version 1.4.4. It is very likely that this update will cause breaking changes to this Docker container. Upon release of 1.4.4, this container's functionality will be reviewed. Relevant issues and fixes will be tracked in the Github Repository. Working 1.4.4 and 1.4.3 tags will be listed during the transition in the README.

---

[View on Github](https://github.com/JACOBSMILE/tmodloader1.4) |
[View on Dockerhub](https://registry.hub.docker.com/r/jacobsmile/tmodloader1.4)

This Docker Image is designed to allow for easy configuration and setup of a modded Terraria server powered by tModLoader.

## Features
- Easy Downloading of tModLoader mods by Workshop ID
- Scheduled World Saving
- Graceful Shutdowns
- Configuration Files are optional
- Github Automation to stay up-to-date with tModLoader's release cycle

## Credits & Mentions
- Terraria
  - [Website](https://terraria.org/)
  - [Steam Store Page](https://store.steampowered.com/app/105600/Terraria/)
- tModLoader
  - [Website](https://www.tmodloader.net/)
  - [Steam Store Page](https://store.steampowered.com/app/1281930/tModLoader/)
  - [Github](https://github.com/tModLoader/tModLoader)
- [ldericher](https://github.com/ldericher/tmodloader-docker)'s Docker implementation of tModLoader for Terraria 1.3 and command injection functionality
- [rfvgyhn](https://github.com/rfvgyhn/tmodloader-docker)'s Docker implementation of tModLoader for Terraria 1.3
- [guillheu](https://github.com/guillheu/tmodloader-docker)'s Docker implementation of tModLoader for Terraria 1.4
- [FlorentLM](https://github.com/FlorentLM/tmodloader1.4) For helping clean up the Dockerfile & resolving some security concerns.

## Check out all of my Terraria Images!

1.4 Vanilla Terraria: [Github](https://github.com/JACOBSMILE/terraria1.4) | [Dockerhub](https://hub.docker.com/r/jacobsmile/terraria1.4)

1.4 tModLoader: [Github](https://github.com/JACOBSMILE/tmodloader1.4) | [Dockerhub](https://hub.docker.com/r/jacobsmile/tmodloader1.4)

# Repository Automation & Daily Automated Builds
The Github repository has been configured with an automated workflow to check for tModLoader updates daily and update the latest image and Dockerfile with the new tModLoader version. 

Additionally, the Dockerhub registry will maintain all previous versions which are processed through this automated workflow. You can access these previous versions by pulling a repository with the tModLoader version string as the tag.

## To Pull the Latest tModLoader Image

```bash
# ":latest" will pull the most recent tModLoader version from https://github.com/tModLoader/tModLoader/releases/latest
docker pull jacobsmile/tmodloader1.4:latest
```

## To Pull a Specific tModLoader Image Version
```bash
# Replace 'v2022.09.47.13' with the version string found at https://github.com/tModLoader/tModLoader/releases
docker pull jacobsmile/tmodloader1.4:v2022.09.47.13
```

# Container Preparation

### Data Directory
Create a directory on HOST machine to house persistent files.

```bash
# Making the Data directory
mkdir /path/to/data/directory
```

```bash
# The below line is a mapped volume for the Docker container.
-v /path/to/data/directory:/data
```

## Downloading Mods
Every Workshop item on Steam has a unique identifier which can be found by visiting the store page directly. For example, for the [Calamity Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2824688072), you can find the Workshop ID from the URL. In this case, **2824688072** is the ID. This Docker container is capable of downloading tModLoader mods directly from the Steam Workshop to streamline the setup process.

In the environment variables passed to the container at runtime, specify the `TMOD_AUTODOWNLOAD` variable with a value of a comma separated list of the Mod IDs you wish to download.

For example, to tell the container to download Calamity and the Calamity Mod Music, specify the following variable:
```bash
-e TMOD_AUTODOWNLOAD=2824688072,2824688266
```

---
## Enabling Mods
To successfully run this container, it is important to understand the difference between **downloading mods** and **enabling mods**.

**Downloading** a mod simply stores it in the Steam Workshop cache, which is stored in the `/data/mods` directory. When mapping `/data` to a HOST directory, this will allow for persistence between container restarts.

**Enabling** a mod tells the container to write the Mod's name to the `enabled.json` file, which tModLoader reads during startup. A Mod must first be downloaded with the `TMOD_AUTODOWNLOAD` variable to be eligible to be enabled.

To enable a mod on the server, specify the `TMOD_ENABLEDMODS` environment variabe with a value of a comma separated list of the Mod IDs you wish to enable. 

```bash
-e TMOD_ENABLEDMODS=2824688072,2824688266
```
---
## Mod Considerations
There is no need to repeatedly download mods each time you start the container. For this reason, once you have downloaded the mods you want to include on your server, it is safe to **remove** the `TMOD_AUTODOWNLOAD` environment variable, whilst maintaining the `TMOD_ENABLEDMODS` variable to enable them during runtime. Doing so will greatly improve the startup time of the Docker container.

If mods receive updates you wish to download, include the Mod ID again in the `TMOD_AUTODOWNLOAD` variable to download the update. The next time tModLoader starts, the mod will be updated.

Additionally, you may at any time remove a mod from the `TMOD_ENABLEDMODS` variable to disable it, though this may cause problems with a world which has modded content.

# Environment Variables
The following are all of the environment variables that are supported by the container. These handle server functionality and Terraria server configurations.

| Variable      | Default Value | Description |
| ----------- | ----------- | ----------- |
| TMOD_SHUTDOWN_MESSAGE | Server is shutting down NOW! | The message which will be sent to the in-game chat upon container shutdown.
| TMOD_AUTOSAVE_INTERVAL   | 10 | The autosave interval (in minutes) in which the World will be saved.
| TMOD_AUTODOWNLOAD | N/A | A Comma Separated list of Workshop Mod IDs to download from Steam upon container startup.
| TMOD_ENABLEDMODS | N/A | A Comma Separated list of Workshop Mod IDs to enable on the tModLoader server upon startup.
| TMOD_USECONFIGFILE | No | If you wish to use a config file to specify server settings, set this variable to "Yes". Please note, this has been deprecated.
| TMOD_MOTD | A tModLoader server powered by Docker! | The Message of the Day which prints in the chat upon joining the server.
| TMOD_PASS | docker | The password players must supply to join the server. Set this variable to "N/A" to disable requiring a password on join. (Not Recommended)
| TMOD_MAXPLAYERS | 8 | The maximum number of players which can join the server at once.
| TMOD_WORLDNAME | Docker | The name of the world file. This is seen in-game as well as will be used for the name of the .WLD file.
| TMOD_WORLDSIZE | 3 | When generating a new world (and only when generating a new world), this variable will be used to designate the size. 1 = Small, 2 = Medium, 3 = Large
| TMOD_WORLDSEED | Docker | The seed for a new world.
| TMOD_DIFFICULTY | 1 | When generating a new world (and only when generating a new world), this variable will set the difficulty of the world. 0 = Normal, 1 = Expert, 2 = Master, 3 = Journey.
| TMOD_SECURE | 0 | Adds additional cheat protection.
| TMOD_LANGUAGE | en-US | Sets the language for the server. Available options are: `en-US` (English), `de-DE` (German), `it-IT` (Italian), `fr-FR` (French), `es-ES` (Spanish), `ru-RU` (Russian), `zh-Hans` (Chinese), `pt-BR` (Portuguese), `pl-PL` (Polish).
| TMOD_NPCSTREAM | 60 | Reduces enemy skipping, but increases bandwidth usage. The lower the number, the less skipping will happeb, but more data is sent. 0 is off.
| TMOD_UPNP | 0 | Automatically forwards ports with uPNP (untested, and may not work in all cases depending on network configuration)

The following are environment variables which control Journey Mode settings. For all of these settings, 
* 0 = Locked for everyone 
* 1 = Only Changeable by Host
* 2 = Can be changed by everyone. 

Refer to the [Terraria Server Wiki](https://terraria.fandom.com/wiki/Server) for more information. The default setting for all of these is 0 when not explicitly set.

* TMOD_JOURNEY_SETFROZEN
* TMOD_JOURNEY_SETDAWN
* TMOD_JOURNEY_SETNOON
* TMOD_JOURNEY_SETDUSK
* TMOD_JOURNEY_SETMIDNIGHT
* TMOD_JOURNEY_GODMODE
* TMOD_JOURNEY_WIND_STRENGTH
* TMOD_JOURNEY_RAIN_STRENGTH
* TMOD_JOURNEY_TIME_SPEED
* TMOD_JOURNEY_RAIN_FROZEN
* TMOD_JOURNEY_WIND_FROZEN
* TMOD_JOURNEY_PLACEMENT_RANGE
* TMOD_JOURNEY_SET_DIFFICULTY
* TMOD_JOURNEY_BIOME_SPREAD
* TMOD_JOURNEY_SPAWN_RATE

# Running the Container

## Docker Command

```bash
# Pull the image
docker pull jacobsmile/tmodloader1.4:latest

# Execute the container
docker run -p 7777:7777 --name tmodloader --rm \
  -v /path/to/data:/data
  -e TMOD_SHUTDOWN_MESSAGE='Goodbye!' \
  -e TMOD_AUTOSAVE_INTERVAL='15' \
  -e TMOD_AUTODOWNLOAD='2824688072,2824688266' \
  -e TMOD_ENABLEDMODS='2824688072,2824688266' \
  -e TMOD_MOTD='Welcome to my tModLoader Server!' \
  -e TMOD_PASS='secret' \
  -e TMOD_MAXPLAYERS='16' \
  -e TMOD_WORLDNAME='Earth' \
  -e TMOD_WORLDSIZE='2' \
  -e TMOD_WORLDSEED='not the bees!' \
  -e TMOD_DIFFICULTY='3' \
  jacobsmile/tmodloader1.4
```

## Docker Compose

Included in the Github repository is a sample `docker-compose.yml` file. Refer to the contents of this file to learn how to configure this file. 

Once you are satisfied with the compose file, start it with the following command.
```bash
docker compose up --build
```

# Interacting with the Server

To send commands to the server once it has started, use the following command on your Host machine. The below example will send "Hello World" to the game chat.

```bash
docker exec tmodloader inject "say Hello World!"
```
You can alernatively use the UID of the container in place of `tmodloader` if you did not name your configuration.

_Credit to [ldericher](https://github.com/ldericher/tmodloader-docker) for this method of command injection to tModLoader's console._

# Notes
I do not own tModLoader or Terraria. This Docker Image was created for players to easily host a game server with Docker, and is not intended to infringe on any Copyright, Trademark or Intellectual Property.
