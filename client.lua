CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.CommandNames.help, 'Show available server commands')
    TriggerEvent('chat:addSuggestion', '/' .. Config.CommandNames.id, 'Show your server ID')
    TriggerEvent('chat:addSuggestion', '/' .. Config.CommandNames.announce, 'Send a staff announcement', {
        { name = 'message', help = 'Announcement text' }
    })
    if Config.VehicleSpawn.Enabled then
        TriggerEvent('chat:addSuggestion', '/' .. Config.VehicleSpawn.Command, 'Spawn a vehicle (authorized staff)', {
            { name = 'model', help = 'Vehicle model name' }
        })
    end
    if Config.StaffDuty.Enabled then
        TriggerEvent('chat:addSuggestion', '/' .. Config.CommandNames.duty, 'Toggle staff duty on or off')
    end
end)

RegisterNetEvent('community_core:spawnVehicle', function(model)
    if type(model) ~= 'string' then
        return
    end

    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        TriggerEvent('chat:addMessage', {
            color = { 235, 90, 90 },
            args = { Config.ServerName, ('Unknown vehicle model: %s'):format(model) }
        })
        return
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(50)
    end
    if not HasModelLoaded(hash) then
        TriggerEvent('chat:addMessage', {
            color = { 235, 90, 90 },
            args = { Config.ServerName, 'Vehicle model failed to load.' }
        })
        return
    end

    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local heading = GetEntityHeading(ped)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    if vehicle == 0 then
        SetModelAsNoLongerNeeded(hash)
        TriggerEvent('chat:addMessage', {
            color = { 235, 90, 90 },
            args = { Config.ServerName, 'Could not create the vehicle.' }
        })
        return
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    local presets = Config.VehicleSpawn.Presets or {}
    local requestedModel = model:lower()
    local modelSettings = presets[requestedModel]
    if not modelSettings then
        for _, preset in pairs(presets) do
            if type(preset) == 'table' and type(preset.Aliases) == 'table' then
                for _, alias in ipairs(preset.Aliases) do
                    if type(alias) == 'string' and alias:lower() == requestedModel then
                        modelSettings = preset
                        break
                    end
                end
            end
            if modelSettings then
                break
            end
        end
    end
    local function resolveSettings(category)
        local override = modelSettings and modelSettings[category]
        if type(override) ~= 'table' then
            return Config.VehicleSpawn[category]
        end
        local resolved = {}
        for key, value in pairs(Config.VehicleSpawn[category] or {}) do
            resolved[key] = value
        end
        for key, value in pairs(override) do
            resolved[key] = value
        end
        return resolved
    end

    local colorSettings = resolveSettings('Colors')
    if colorSettings and colorSettings.Enabled then
        SetVehicleColours(vehicle, colorSettings.Primary or 0, colorSettings.Secondary or 0)
    end

    local extraSettings = resolveSettings('Extras')
    if extraSettings and extraSettings.Enabled then
        for extraId, enabled in pairs(extraSettings) do
            if type(extraId) == 'number' and type(enabled) == 'boolean' and DoesExtraExist(vehicle, extraId) then
                SetVehicleExtra(vehicle, extraId, enabled and 0 or 1)
            end
        end
    end

    local performance = resolveSettings('Performance')
    if performance and performance.Enabled then
        local mods = {
            { Slot = 11, Level = performance.Engine },
            { Slot = 12, Level = performance.Brakes },
            { Slot = 13, Level = performance.Transmission },
            { Slot = 15, Level = performance.Suspension },
            { Slot = 16, Level = performance.Armor }
        }

        SetVehicleModKit(vehicle, 0)
        for _, mod in ipairs(mods) do
            local count = GetNumVehicleMods(vehicle, mod.Slot)
            if type(mod.Level) == 'number'
                and mod.Level == math.floor(mod.Level)
                and mod.Level >= -1
                and mod.Level < count then
                SetVehicleMod(vehicle, mod.Slot, mod.Level, false)
            end
        end

        if type(performance.Turbo) == 'boolean' then
            ToggleVehicleMod(vehicle, 18, performance.Turbo)
        end
    end

    local liverySettings = resolveSettings('Livery')
    if liverySettings and liverySettings.Enabled then
        local liveryIndex = liverySettings.Index or 0
        if type(liveryIndex) == 'number' and liveryIndex >= 0 and liveryIndex == math.floor(liveryIndex) then
            if liverySettings.Mode == 'mod' then
                local modCount = GetNumVehicleMods(vehicle, 48)
                if liveryIndex < modCount then
                    SetVehicleMod(vehicle, 48, liveryIndex, false)
                end
            elseif liverySettings.Mode == 'native' then
                local liveryCount = GetVehicleLiveryCount(vehicle)
                if liveryCount > 0 and liveryIndex < liveryCount then
                    SetVehicleLivery(vehicle, liveryIndex)
                end
            end
        end
    end

    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
end)

local dutyBlips = {}
local dutyOutfitApplied = false
local savedOutfit = nil

local function isIndexInRange(value, count)
    return type(value) == 'number'
        and value >= 0
        and value == math.floor(value)
        and value < count
end

local function applyDutyOutfit(enabled)
    local settings = Config.StaffDuty.Outfit
    if not settings or not settings.Enabled then
        return
    end

    local ped = PlayerPedId()
    if enabled then
        if dutyOutfitApplied then
            return
        end

        savedOutfit = { Components = {}, Props = {} }
        for _, component in ipairs(settings.Components or {}) do
            local id = component.Id
            local drawable = component.Drawable
            local texture = component.Texture or 0
            local drawableCount = type(id) == 'number' and GetNumberOfPedDrawableVariations(ped, id) or 0
            local textureCount = isIndexInRange(drawable, drawableCount)
                and GetNumberOfPedTextureVariations(ped, id, drawable) or 0

            if isIndexInRange(drawable, drawableCount) and isIndexInRange(texture, textureCount) then
                savedOutfit.Components[id] = {
                    Drawable = GetPedDrawableVariation(ped, id),
                    Texture = GetPedTextureVariation(ped, id),
                    Palette = GetPedPaletteVariation(ped, id)
                }
                SetPedComponentVariation(ped, id, drawable, texture, component.Palette or 0)
            else
                print(('[community_core] Skipping invalid duty component (slot %s, drawable %s, texture %s)')
                    :format(tostring(id), tostring(drawable), tostring(texture)))
            end
        end
        for _, prop in ipairs(settings.Props or {}) do
            local id = prop.Id
            local drawable = prop.Drawable
            local texture = prop.Texture or 0
            local drawableCount = type(id) == 'number' and GetNumberOfPedPropDrawableVariations(ped, id) or 0
            local validDrawable = drawable == -1 or isIndexInRange(drawable, drawableCount)
            local textureCount = drawable ~= -1 and validDrawable
                and GetNumberOfPedPropTextureVariations(ped, id, drawable) or 0

            if validDrawable and (drawable == -1 or isIndexInRange(texture, textureCount)) then
                local currentDrawable = GetPedPropIndex(ped, id)
                savedOutfit.Props[id] = {
                    Drawable = currentDrawable,
                    Texture = currentDrawable >= 0 and GetPedPropTextureIndex(ped, id) or 0
                }
                if drawable == -1 then
                    ClearPedProp(ped, id)
                else
                    SetPedPropIndex(ped, id, drawable, texture, true)
                end
            else
                print(('[community_core] Skipping invalid duty prop (slot %s, drawable %s, texture %s)')
                    :format(tostring(id), tostring(drawable), tostring(texture)))
            end
        end
        dutyOutfitApplied = true
        return
    end

    if not dutyOutfitApplied or not savedOutfit then
        return
    end

    for id, component in pairs(savedOutfit.Components) do
        SetPedComponentVariation(ped, id, component.Drawable, component.Texture, component.Palette)
    end
    for id, prop in pairs(savedOutfit.Props) do
        if prop.Drawable < 0 then
            ClearPedProp(ped, id)
        else
            SetPedPropIndex(ped, id, prop.Drawable, prop.Texture, true)
        end
    end
    dutyOutfitApplied = false
    savedOutfit = nil
end

RegisterNetEvent('community_core:setDutyOutfit', function(enabled)
    applyDutyOutfit(enabled == true)
end)

AddEventHandler('playerSpawned', function()
    if dutyOutfitApplied then
        applyDutyOutfit(false)
    end
    TriggerServerEvent('community_core:requestDutyState')
end)

local function removeBlip(serverId)
    local blip = dutyBlips[serverId]
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    dutyBlips[serverId] = nil
end

local function updateBlip(serverId, enabled)
    local settings = Config.StaffDuty.Blips
    if not settings.Enabled or serverId == GetPlayerServerId(PlayerId()) then
        removeBlip(serverId)
        return
    end

    local player = GetPlayerFromServerId(serverId)
    if player == -1 then
        removeBlip(serverId)
        return
    end

    local blip = dutyBlips[serverId]
    if not enabled then
        removeBlip(serverId)
        return
    end

    local ped = GetPlayerPed(player)
    if not DoesEntityExist(ped) then
        removeBlip(serverId)
        return
    end

    if not blip or not DoesBlipExist(blip) then
        blip = AddBlipForEntity(ped)
        dutyBlips[serverId] = blip
        SetBlipSprite(blip, settings.Sprite)
        SetBlipColour(blip, settings.Color)
        SetBlipScale(blip, settings.Scale)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(settings.Name)
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ownPlayer = PlayerId()
        local ownCoords = GetEntityCoords(PlayerPedId())
        local tags = Config.StaffDuty.NameTags
        local drawTags = tags.Enabled
        local color = tags.Color

        if drawTags then
            sleep = 0
            for _, player in ipairs(GetActivePlayers()) do
                if player ~= ownPlayer then
                    local serverId = GetPlayerServerId(player)
                    local state = Player(serverId).state
                    if state['community:onDuty'] then
                        local ped = GetPlayerPed(player)
                        if DoesEntityExist(ped) then
                            local coords = GetEntityCoords(ped)
                            if #(ownCoords - coords) <= tags.DrawDistance then
                                local name = GetPlayerName(player) or 'Staff'
                                local text = tags.Text:gsub('{player}', name)
                                local x, y, z = table.unpack(coords)
                                SetDrawOrigin(x, y, z + tags.Height, 0)
                                SetTextFont(4)
                                SetTextScale(0.32, 0.32)
                                SetTextColour(color[1], color[2], color[3], 255)
                                SetTextCentre(true)
                                SetTextOutline()
                                BeginTextCommandDisplayText('STRING')
                                AddTextComponentString(text)
                                EndTextCommandDisplayText(0.0, 0.0)
                                ClearDrawOrigin()
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local active = {}
        for _, player in ipairs(GetActivePlayers()) do
            local serverId = GetPlayerServerId(player)
            active[serverId] = true
            local enabled = Player(serverId).state['community:onDuty'] == true
            updateBlip(serverId, enabled)
        end
        for serverId in pairs(dutyBlips) do
            if not active[serverId] then
                removeBlip(serverId)
            end
        end
        Wait(1000)
    end
end)
