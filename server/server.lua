local function getCurrentDate()
    return os.date("%Y-%m-%d")
end

local function saveDataToJsonFile(data, baseFilename)
    local currentDate = getCurrentDate()
    local filenameWithDate = baseFilename .. "_" .. currentDate .. ".json"

    local dataWithDate = {
        date = currentDate,
        note = "This file contains a summary of duplicate weapons, including weapon series, quality, ammo, and player information.",
        data = data
    }

    local fileData = json.encode(dataWithDate, { indent = true })
    SaveResourceFile(GetCurrentResourceName(), filenameWithDate, fileData, -1)
end

local function sortTableByDuplicateCount(tbl)
    local sorted = {}
    for citizenid, details in pairs(tbl) do
        local entry = {
            citizenid = citizenid,
            count = details.count,
            license = details.license
        }
        -- Add the weapons array after the other properties
        entry.weapons = details.weapons
        table.insert(sorted, entry)
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    return sorted
end

local function checkForDuplicateWeaponSeries()
    local query = 'SELECT citizenid, license, JSON_UNQUOTE(JSON_EXTRACT(inventory, "$")) as inventory FROM players'

    exports.oxmysql:execute(query, {}, function(players)
        if players then
            local seriesTracker = {}
            local citizenDuplicateCount = {}
            local resultsToSave = {}
            local processedCount = 0

            for _, player in pairs(players) do
                if player.inventory and player.inventory ~= "" then
                    local inventory = json.decode(player.inventory)

                    if inventory then
                        for _, item in pairs(inventory) do
                            if item.type == 'weapon' and not item.info.isScratched then
                                local series = item.info.serie
                                local weaponName = item.name
                                local quality = item.info.quality or 'unknown'
                                local ammo = item.info.ammo

                                -- Check if ammo is '-1' and label it as 'modded'
                                if ammo == -1 then
                                    ammo = 'modded'
                                else
                                    ammo = ammo or 'unknown'
                                end

                                if seriesTracker[series] then
                                    table.insert(seriesTracker[series], {citizenid = player.citizenid, weapon = weaponName, license = player.license, series = series, quality = quality, ammo = ammo})
                                    citizenDuplicateCount[player.citizenid] = citizenDuplicateCount[player.citizenid] or {count = 0, license = player.license, weapons = {}}
                                    citizenDuplicateCount[player.citizenid].count = citizenDuplicateCount[player.citizenid].count + 1
                                    table.insert(citizenDuplicateCount[player.citizenid].weapons, {name = weaponName, series = series, quality = quality, ammo = ammo})
                                else
                                    seriesTracker[series] = {{citizenid = player.citizenid, weapon = weaponName, license = player.license, series = series, quality = quality, ammo = ammo}}
                                end
                            end
                        end
                    end
                end

                processedCount = processedCount + 1
                if processedCount % 100 == 0 then
                    print("Processed 100 players, waiting for 1 seconds...")
                    Citizen.Wait(1000)
                end
            end

            for series, details in pairs(seriesTracker) do
                if #details > 1 then
                    local citizenIds = {}
                    local weaponDetails = {}
                    for _, detail in ipairs(details) do
                        table.insert(citizenIds, detail.citizenid)
                        table.insert(weaponDetails, {name = detail.weapon, series = detail.series, quality = detail.quality, ammo = detail.ammo})
                    end
                    local duplicateInfo = { series = series, weapons = weaponDetails, citizenIds = citizenIds }
                    table.insert(resultsToSave, duplicateInfo)
                end
            end

            if #resultsToSave > 0 then
                saveDataToJsonFile(resultsToSave, "duplicateWeapons")
            end

            local sortedSummary = sortTableByDuplicateCount(citizenDuplicateCount)
            if next(citizenDuplicateCount) then
                saveDataToJsonFile(sortedSummary, "duplicateSummary")
            end

            print("Duplicate weapon series check completed.")
        else
            print('Unable to retrieve data.')
        end
    end)
end

RegisterCommand('checkdupeweapons', function(source, args, rawCommand)
    if source == 0 then
        checkForDuplicateWeaponSeries()
    else
        print('This command can only be run from the server console.')
    end
end, true)
