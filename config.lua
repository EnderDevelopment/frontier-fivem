Config = {}

Config.ServerName = 'Community Server'
Config.WelcomeMessage = 'Welcome to {server}, {player}!'
Config.AnnouncementAce = 'community.announce'
Config.VehicleSpawn = {
    Enabled = true,
    Ace = 'community.vehicle',
    Command = 'car',
    -- Empty means any valid vehicle model can be requested.
    AllowedModels = {},
    Colors = {
        Enabled = false,
        Primary = 0,
        Secondary = 0
    },
    Extras = {
        Enabled = false
        -- Add entries such as [1] = true to enable or [2] = false to disable extras.
    },
    Livery = {
        Enabled = false,
        -- Mode can be 'native' or 'mod'. Index is zero-based.
        Mode = 'native',
        Index = 0
    },
    Performance = {
        Enabled = false,
        -- Mod levels use -1 for stock and 0 through the vehicle's available levels.
        Engine = -1,
        Brakes = -1,
        Transmission = -1,
        Suspension = -1,
        Armor = -1,
        Turbo = false
    },
    -- Presets are keyed by lowercase model name and override only listed categories.
    Presets = {
        -- Each preset overrides only the categories it defines.
        -- sultan = {
        --     Aliases = { 'sultan2', 'sultanrs' },
        --     Colors = { Enabled = true, Primary = 0, Secondary = 0 },
        --     Performance = { Enabled = true, Engine = 2, Brakes = 2, Turbo = true }
        -- },
        -- blista = {
        --     Colors = { Enabled = true, Primary = 111, Secondary = 0 },
        --     Extras = { Enabled = true, [1] = true, [2] = false }
        -- },
        -- comet = {
        --     Colors = { Enabled = true, Primary = 12, Secondary = 111 }
        -- },
        -- mesa = {
        --     Extras = { Enabled = true, [1] = true, [2] = true, [3] = false }
        -- },
        -- police = {
        --     Livery = { Enabled = true, Mode = 'native', Index = 0 },
        --     Performance = { Enabled = true, Engine = 3, Brakes = 2, Transmission = 2, Armor = 3 }
        -- },
        -- sheriff = {
        --     Aliases = { 'sheriff2' },
        --     Livery = { Enabled = true, Mode = 'mod', Index = 1 }
        -- },
        -- ambulance = {
        --     Livery = { Enabled = true, Mode = 'mod', Index = 2 }
        -- },
        -- Branded-style examples use built-in GTA model names; adjust colors and mods per vehicle.
        -- elegy = {
        --     Colors = { Enabled = true, Primary = 0, Secondary = 111 },
        --     Performance = { Enabled = true, Engine = 3, Brakes = 2, Transmission = 2, Turbo = true }
        -- },
        -- buffalo = {
        --     Colors = { Enabled = true, Primary = 27, Secondary = 0 },
        --     Performance = { Enabled = true, Engine = 2, Brakes = 2, Transmission = 2 }
        -- },
        -- dominator = {
        --     Colors = { Enabled = true, Primary = 28, Secondary = 0 },
        --     Performance = { Enabled = true, Engine = 3, Brakes = 3, Transmission = 2, Turbo = true }
        -- }
    }
}
Config.StaffDuty = {
    Enabled = true,
    Ace = 'community.duty',
    AnnounceChanges = false,
    OnMessage = 'You are now on staff duty.',
    OffMessage = 'You are now off staff duty.',
    OnAnnouncement = '{player} is now on staff duty.',
    OffAnnouncement = '{player} is now off staff duty.',
    Blips = {
        Enabled = true,
        Sprite = 1,
        Color = 2,
        Scale = 0.85,
        Name = 'On-duty staff'
    },
    NameTags = {
        Enabled = true,
        DrawDistance = 25.0,
        Text = '[STAFF] {player}',
        Color = { 100, 200, 255 },
        Height = 1.15
    },
    Outfit = {
        Enabled = false,
        Components = {
            -- { Id = 11, Drawable = 1, Texture = 0, Palette = 0 }
        },
        Props = {
            -- { Id = 0, Drawable = -1, Texture = 0 }
        }
    }
}
Config.CommandNames = {
    help = 'help',
    id = 'id',
    announce = 'announce',
    duty = 'duty'
}
