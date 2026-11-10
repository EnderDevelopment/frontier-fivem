# FiveM Community Server Resource

Frontier FiveM is a standalone FiveM resource for community servers, providing player welcome messages, chat commands, staff announcements and duty status, plus permission-controlled vehicle spawning. It uses FiveM’s built-in chat resource and does not require ESX, QBCore, or external libraries.

## Install

1. Place the resource folder in your server’s `resources` directory.
2. Add the following to `server.cfg`, changing `community_core` if you rename the folder:

```cfg
ensure chat
ensure community_core
add_ace group.admin community.announce allow
add_ace group.admin community.duty allow
add_ace group.admin community.vehicle allow
```

3. Assign trusted staff to the permitted group using your server’s existing identifier and principal setup.
4. Start or restart the server.

## Use

- `/help` lists the available commands.
- `/id` displays your server ID.
- `/announce <message>` broadcasts an announcement to all players with the `community.announce` ACE permission.
- `/duty` toggles staff duty for players with the `community.duty` ACE permission. Duty status is replicated as `community:onDuty`; optional map blips and nearby name tags show on-duty staff.
- `/car <model>` spawns a vehicle for players with the `community.vehicle` ACE permission. Configure `Config.VehicleSpawn` to disable vehicle spawning, restrict models, or set vehicle colors, extras, liveries, performance, and model-specific presets.
- Edit `config.lua` to configure the server name, welcome message, command names, permissions, duty messages and visual settings. Duty outfits can also be configured there and are disabled by default.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/fc74eb96-5c20-4d91-a4e4-794079424981?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=fc74eb96-5c20-4d91-a4e4-794079424981
