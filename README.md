# FiveM Server Utility Resource

A standalone FiveM resource that adds community server commands, player welcome messages, staff announcements and duty tools, plus permission-controlled vehicle spawning. It uses FiveM’s built-in chat resource and does not require ESX, QBCore, or external libraries.

## Install

1. Place the resource folder in your server’s `resources` directory.
2. Add the following to `server.cfg`:

```cfg
ensure chat
ensure community_core
add_ace group.admin community.announce allow
add_ace group.admin community.duty allow
add_ace group.admin community.vehicle allow
```

3. Assign trusted staff to the permitted ACE group using your server’s principal setup.
4. Start or restart the server.

## Use

- Players can use `/help` to list commands and `/id` to display their server ID.
- Authorized staff can use `/announce <message>` to broadcast an announcement, `/duty` to toggle staff duty, and `/car <model>` to spawn a vehicle.
- Edit `config.lua` to set the server name, welcome message, command names, permissions, and vehicle or duty settings.
- Vehicle spawning can be restricted with `Config.VehicleSpawn.AllowedModels`. Vehicle colors, extras, liveries, performance upgrades, and per-model presets can be configured there.
- Staff duty state is replicated as `community:onDuty`. Optional map blips, nearby name tags, duty announcements, and configurable duty outfits are available in `Config.StaffDuty`.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/fc74eb96-5c20-4d91-a4e4-794079424981?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=fc74eb96-5c20-4d91-a4e4-794079424981
