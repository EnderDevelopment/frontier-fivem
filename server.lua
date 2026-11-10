local function sendMessage(target, message, color)
    TriggerClientEvent('chat:addMessage', target, {
        color = color or { 90, 190, 255 },
        multiline = true,
        args = { Config.ServerName, message }
    })
end

local function trim(value)
    return value:match('^%s*(.-)%s*$')
end

local staffOnDuty = {}

local function isAllowedVehicle(model)
    if type(model) ~= 'string' or #model < 1 or #model > 32 or not model:match('^[%w_%-]+$') then
        return false
    end

    local allowedModels = Config.VehicleSpawn.AllowedModels
    if #allowedModels == 0 then
        return true
    end

    local requested = model:lower()
    for _, allowed in ipairs(allowedModels) do
        if type(allowed) == 'string' and allowed:lower() == requested then
            return true
        end
    end
    return false
end

if Config.VehicleSpawn.Enabled then
    RegisterCommand(Config.VehicleSpawn.Command, function(source, args)
        if source == 0 then
            print(('Usage: /%s <vehicle model> (in-game only)'):format(Config.VehicleSpawn.Command))
            return
        end
        if not IsPlayerAceAllowed(source, Config.VehicleSpawn.Ace) then
            sendMessage(source, 'You do not have permission to spawn vehicles.', { 235, 90, 90 })
            return
        end

        local model = args[1]
        if not model or not isAllowedVehicle(model) then
            sendMessage(source, ('Usage: /%s <vehicle model>%s'):format(
                Config.VehicleSpawn.Command,
                #Config.VehicleSpawn.AllowedModels > 0 and ' (model is not in the configured allowlist)' or ''
            ), { 235, 190, 90 })
            return
        end
        TriggerClientEvent('community_core:spawnVehicle', source, model)
    end, false)
end

local function setStaffDuty(playerId, enabled)
    staffOnDuty[playerId] = enabled or nil
    local player = Player(playerId)
    if player then
        player.state:set('community:onDuty', enabled, true)
        TriggerClientEvent('community_core:setDutyOutfit', playerId, enabled)
    end

    local message = enabled and Config.StaffDuty.OnMessage or Config.StaffDuty.OffMessage
    sendMessage(playerId, message, enabled and { 90, 220, 140 } or { 180, 180, 180 })

    if Config.StaffDuty.AnnounceChanges then
        local template = enabled and Config.StaffDuty.OnAnnouncement or Config.StaffDuty.OffAnnouncement
        local announcement = template:gsub('{player}', GetPlayerName(playerId) or 'Staff')
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 180, 120, 255 },
            multiline = true,
            args = { 'STAFF DUTY', announcement }
        })
    end
end

RegisterNetEvent('community_core:requestDutyState', function()
    local playerId = source
    TriggerClientEvent('community_core:setDutyOutfit', playerId, staffOnDuty[playerId] == true)
end)

AddEventHandler('playerDropped', function()
    staffOnDuty[source] = nil
end)

AddEventHandler('playerJoining', function()
    local playerId = source
    local playerName = GetPlayerName(playerId) or 'Player'
    local message = Config.WelcomeMessage
        :gsub('{server}', Config.ServerName)
        :gsub('{player}', playerName)

    SetTimeout(1500, function()
        if GetPlayerName(playerId) then
            sendMessage(playerId, message, { 90, 220, 140 })
        end
    end)
end)

RegisterCommand(Config.CommandNames.help, function(source)
    local commands = ('Commands: /%s shows your server ID; /%s <message> sends a staff announcement.'):format(
        Config.CommandNames.id,
        Config.CommandNames.announce
    )
    if Config.StaffDuty.Enabled then
        commands = commands .. (' /%s toggles staff duty.'):format(Config.CommandNames.duty)
    end
    if Config.VehicleSpawn.Enabled then
        commands = commands .. (' /%s <model> spawns a vehicle for authorized staff.'):format(Config.VehicleSpawn.Command)
    end
    if source == 0 then
        print(commands)
    else
        sendMessage(source, commands)
    end
end, false)

RegisterCommand(Config.CommandNames.id, function(source)
    if source == 0 then
        print('This command is for players in-game.')
        return
    end
    sendMessage(source, ('Your server ID is %d.'):format(source))
end, false)

RegisterCommand(Config.CommandNames.announce, function(source, args)
    if source == 0 then
        print(('Usage: /%s <message>'):format(Config.CommandNames.announce))
        return
    end
    if not IsPlayerAceAllowed(source, Config.AnnouncementAce) then
        sendMessage(source, 'You do not have permission to make announcements.', { 235, 90, 90 })
        return
    end

    local message = trim(table.concat(args, ' '))
    if message == '' then
        sendMessage(source, ('Usage: /%s <message>'):format(Config.CommandNames.announce), { 235, 190, 90 })
        return
    end

    local author = GetPlayerName(source) or 'Staff'
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 190, 70 },
        multiline = true,
        args = { 'ANNOUNCEMENT', ('%s: %s'):format(author, message) }
    })
end, false)

if Config.StaffDuty.Enabled then
    RegisterCommand(Config.CommandNames.duty, function(source)
        if source == 0 then
            print(('Usage: /%s (in-game only)'):format(Config.CommandNames.duty))
            return
        end
        if not IsPlayerAceAllowed(source, Config.StaffDuty.Ace) then
            sendMessage(source, 'You do not have permission to use staff duty.', { 235, 90, 90 })
            return
        end
        setStaffDuty(source, not staffOnDuty[source])
    end, false)
end
