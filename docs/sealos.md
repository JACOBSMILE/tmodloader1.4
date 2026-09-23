# Deploy on Sealos

The community-maintained Sealos template runs this project's tModLoader image with a generated join password, public TCP access, and persistent worlds and Workshop downloads.

## Deploy and connect

You need a Sealos account, Terraria, and a matching tModLoader client.

[![Deploy on Sealos](<https://sealos.io/Deploy-on-Sealos.svg>)](<https://sealos.io/products/app-store/tmodloader/>)

1. Click **Deploy Now**. Choose `world_size` (1 = Small, 2 = Medium, 3 = Large) and `difficulty` (0 = Classic, 1 = Expert, 2 = Master, 3 = Journey).
2. Optionally enter comma-separated numeric Workshop IDs in `workshop_mods`. The template maps these to `TMOD_AUTODOWNLOAD` and `TMOD_ENABLEDMODS`.
3. Wait for Ready status and `Server started` in the logs. First startup downloads the .NET runtime and generates a world.
4. Copy the public TCP host and allocated port from the network resource card, and retrieve `TMOD_PASS` from the server's environment settings.
5. In a matching tModLoader client, choose **Multiplayer → Join via IP**, enter that host and public port, and provide the join password. Match the server's mod versions and dependencies.

The template pins `jacobsmile/tmodloader1.4:v2026.07.3.0`, providing tModLoader v2026.7.3.0 for Terraria 1.4.4.9. Its tested small-world baseline is 100m CPU and 1024 MiB memory. Increase resources for active players, larger worlds, and heavier mods; the eight-player setting is a connection limit.

## Persistence and administration

A 1 GiB persistent volume at `/data` holds worlds in `tModLoader/Worlds`, mod settings in `tModLoader/Mods`, and Workshop content in `steamMods`. World size and difficulty apply when a new world is generated. Empty `workshop_mods` reuses saved enabled-mod settings, initially empty on a fresh volume.

Open the container terminal to run `inject "playing"` or `inject "save"`. Autosave runs every 10 minutes, and graceful shutdown uses the upstream save/exit handler. Save and stop the server before backing up `/data` externally. Expand the volume as needed and keep one replica per world.

## Versions and support

Back up the world before changing the image tag or mods, and coordinate client and server versions. The pinned image requires .NET invariant globalization settings, which the template supplies. Mods requiring locale-specific formatting or collation need an ICU-equipped runtime image.

Recorded Sealos tests covered password rejection/acceptance, native world-data exchange, console commands, persistent saves, graceful shutdown, and Recipe Browser v0.12.0.3. Graphical-client gameplay and capacity for eight active players remain outside that test coverage.

See the [versioned template](https://github.com/labring-actions/templates/blob/bbf343d8fd5cdad7c5cec6ee80d947b66da69fba/template/tmodloader/index.yaml) and [recorded deployment checks](https://github.com/labring-actions/templates/pull/762). For template configuration, Sealos networking, and storage issues, use the [Sealos templates issue tracker](https://github.com/labring-actions/templates/issues).
