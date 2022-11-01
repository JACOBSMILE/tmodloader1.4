# tModLoader Powered By Docker

[View on Github](https://github.com/JACOBSMILE/tmodloader1.4) |
[View on Dockerhub](https://hub.docker.com/repository/docker/jacobsmile/tmodloader1.4)

This Docker Image is designed to allow for easy configuration and setup of a modded Terraria server powered by tModLoader.

## Features
- Easy Downloading of tModLoader mods by Workshop ID
- Scheduled World Saving
- Graceful Shutdowns
- Configuration Files are optional

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

# Container Preparation

### World Directory (Required for Persistent Worlds)
Create a directory on Host machine to house the world file as well as backups.
```bash
# Making the Worlds directory and exporting it to a variable.
mkdir /path/to/worlds/directory
export TMOD_WORLDS=/path/to/worlds/directory
```
_You can omit this, though the worlds will not be saved after your container shuts down! You have been warned._

---

### Steam Workshop Directory (Optional)
Create a directory on the Host machine to house the Steam Workshop files for the tModLoader mods to download to.

This is optional, but including this in your configuration will **greatly reduce the startup time** after the mods have been downloaded from Steam.
```bash
# Making the Workshop directory and exporting it to a variable.
mkdir /path/to/workshop/directory
export TMOD_WORKSHOP=/path/to/workshop/directory
```
---

### Server Configuration File (Optional)
If you would rather have the server read from a configuration file, you may map the configuration file directly. Be sure to set the `TMOD_USECONFIGFILE` environment variable to a value of `YES`.

Refer to the [Terraria Server Documentation]((https://terraria.fandom.com/wiki/Server#Server_config_file)) on how to setup a configuration file.

```bash
# Exporting the path to the config.txt to a variable
export TMOD_CONFIGFILE=/path/to/config.txt
```
---

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

**Downloading** a mod simply stores it in the Steam Workshop cache, which should be mapped to a Host machine directory for persistence between container restarts.

**Enabling** a mod tells the container to write the Mod's name to the `enabled.json` file, which tModLoader reads during startup. A Mod must first be downloaded with the `TMOD_AUTODOWNLOAD` variable to be eligible to be enabled.

To enable a mod on the server, specify the `TMOD_ENABLEDMODS` environment variabe with a value of a comma separated list of the Mod IDs you wish to enable. 

```bash
-e TMOD_ENABLEDMODS=2824688072,2824688266
```
---
## Mod Considerations
Assuming you map a persistant location on your Host machine to store the Workshop content, there is no need to repeatedly download mods each time you start the container. For this reason, once you have downloaded the mods you want to include on your server, it is safe to **remove** the `TMOD_AUTODOWNLOAD` environment variable, whilst maintaining the `TMOD_ENABLEDMODS` variable to enable them during runtime. Doing so will greatly improve the startup time of the Docker container.

If mods receive updates you wish to download, include the Mod ID again in the `TMOD_AUTODOWNLOAD` variable to download the update. The next time tModLoader starts, the mod will be updated.

Additionally, you may at any time remove a mod from the `TMOD_ENABLEDMODS` variable to disable it, though this may cause problems with a world which has modded content.

---

# Environment Variables
The following are all of the environment variables that are supported by the container.

| Variable      | Default Value | Description |
| ----------- | ----------- | ----------- |
| TMOD_SHUTDOWN_MESSAGE | Server is shutting down NOW! | The message which will be sent to the in-game chat upon container shutdown.
| TMOD_AUTOSAVE_INTERVAL   | 10 | The autosave interval (in minutes) in which the World will be saved.
| TMOD_AUTODOWNLOAD | N/A | A Comma Separated list of Workshop Mod IDs to download from Steam upon container startup.
| TMOD_ENABLEDMODS | N/A | A Comma Separated list of Workshop Mod IDs to enable on the tModLoader server upon startup. 
| TMOD_MOTD | A tModLoader server powered by Docker! | The Message of the Day which prints in the chat upon joining the server.
| TMOD_PASS | docker | The password players must supply to join the server. Set this variable to "N/A" to disable requiring a password on join. (Not Recommended)
| TMOD_MAXPLAYERS | 8 | The maximum number of players which can join the server at once.
| TMOD_WORLDNAME | Docker | The name of the world file. This is seen in-game as well as will be used for the name of the .WLD file.
| TMOD_WORLDSIZE | 3 | When generating a new world, this variable will be used to designate the size. 1 = Small, 2 = Medium, 3 = Large
| TMOD_WORLDSEED | Docker | The seed for a new world.
| TMOD_USECONFIGFILE | No | If you wish to use a config file  to specify MOTD, Password, Max Players, World Name, World Size, World Seed, and a few other additional settings, set this to "Yes".

# Running the Container

## Docker Command

```bash
# Pull the image
docker pull jacobsmile/tmodloader-docker:latest

# Execute the container
docker run -p 7777:7777 --name tmodloader --rm \
  -v $TMOD_WORLDS:/root/.local/share/Terraria/tModLoader/Worlds \
  -v $TMOD_WORKSHOP:/root/terraria-server/workshop-mods \
  -v $TMOD_CONFIGFILE:/root/terraria-server/config.txt \
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
  -e TMOD_USECONFIGFILE='No' \
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
I do not own tModLoader or Terraria. This Docker Image was created for players to easily host a game server with Docker, and is not intended to infringe on any Copywrite, Trademark or Intellectual Property.

Feel free to fork this repository and improve upon it if you wish. I plan to keep it as up-to-date as I can. Updating the tModLoader version should be as easy as changing the TMOD_VERSION argument in the Dockerfile.

