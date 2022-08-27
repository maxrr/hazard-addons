rlld                 = rlld or {} // establish globals
rlld.playerCache     = rlld.playerCache or {}
rlld.playerCooldowns = rlld.playerCooldowns or {}
rlld.playerCooldowns.refresh = rlld.playerCooldowns.refresh or {}
rlld.playerCooldowns.selection = rlld.playerCooldowns.selection or {}
rlld.playerCooldowns.modify = rlld.playerCooldowns.modify or {}

// establish boilerplates
local function generateBoilerplate(num)
    if not num then return end
    return {
        ["name"] = "Default Loadout",
        ["index"] = num,
        ["weps"] = {
            "weapon_pistol",
            "weapon_physgun",
            "weapon_medkit",
            "gmod_tool",
            "gmod_camera",
            "keypad_cracker",
            "none",
        }
    }
end

local function uniqueEntriesOnly(tab)
    local temp = {}
    for k, v in pairs(tab) do
        if not table.HasValue(temp, v) then
            table.insert(temp, v)
        end
    end
    return temp
end

//PrintTable(uniqueEntriesOnly({'1', '1', '2', '3', '4', '4', '4'}))

local tBoilerplateData = {
    ["lastSelected"] = 1,
    ["loadouts"] = {
        generateBoilerplate(1),
        generateBoilerplate(2),
        generateBoilerplate(3),
        generateBoilerplate(4),
        generateBoilerplate(5),
        generateBoilerplate(6),
        generateBoilerplate(7),
        generateBoilerplate(8),
        generateBoilerplate(9),
        generateBoilerplate(10)
    }
}

// verify directory exists
hook.Add("InitPostEntity", "rl_loadout_initialspawn", function()
    if not file.IsDir("rl_loadouts", "DATA") then
        file.CreateDir("rl_loadouts")
    end
end)

// setup garbage collection
timer.Create("rlld_delgarbo", 15, 0, function()
    for k, v in pairs(rlld.playerCache) do
        if not IsValid(k) then rlld.playerCache[k] = nil end
    end
    for k, v in pairs(rlld.playerCooldowns) do
        for l, x in pairs(v) do
            if not IsValid(l) then rlld.playerCooldowns[k][l] = nil end
        end
    end
end)

// player connection events
hook.Add("PlayerInitialSpawn", "rl_loadout_connect&cache", function(ply)

    local sSteam64 = ply:SteamID64()
    local sFilename = "rl_loadouts/" .. sSteam64 .. ".txt"
    if not file.Exists(sFilename, "DATA") then
        ply:rlldInitializeNewPlayer()
    else
        ply:rlldCacheLoadouts()
    end

end)

// define global meta funcs
local meta = FindMetaTable("Player")
function meta:rlldGiveWepsList(weps)
    for k, v in pairs(weps) do
        self:Give(v)
    end
end

function meta:rlldRetrieveLoadout(index)
    -- TODO: add retrieve functionality
end

function meta:rlldInitializeNewPlayer()

    print("Player " .. self:Nick() .. " requires new entry, creating...")

    local sFilename = "rl_loadouts/" .. self:SteamID64() .. ".txt"
    file.Write(sFilename, util.TableToJSON(tBoilerplateData))

    self:rlldCacheLoadouts()

end

function meta:rlldCacheLoadouts()
    if rlld.playerCache == nil then return false end

    print("Attempting to retrieve loadout data for: " .. self:Nick() .. "...")

    local sSteam64 = self:SteamID64()
    local sFilename = "rl_loadouts/" .. sSteam64 .. ".txt"
    local sFileContents = file.Read(sFilename, "DATA")

    print("Found loadout data for: " .. self:Nick() .. ", caching...")

    local sFileCompressed = util.Compress(sFileContents)

    net.Start("rl_loadout_dump")
        net.WriteData(sFileCompressed, #sFileCompressed)
    net.Send(self)

    rlld.playerCache[self] = util.JSONToTable(sFileContents)

    print("Success! Cached " .. self:Nick() .. "'s loadouts and sent to client")
end

function meta:rlldSaveFromCache()
    if not IsValid(self) then return end
    if not rlld.playerCache[self] then return end
    if not self:SteamID64() then return end
    file.Write("rl_loadouts/" .. self:SteamID64() .. ".txt", util.TableToJSON(rlld.playerCache[self]))
end

function meta:rlldAuditLoadout(weps)
    if not weps then return false end
    if type(weps) != "table" then return false end

    local tDisallowed = {}

    for k, v in pairs(weps) do
        if not self:canAccess(v, "swep") then
            table.insert(tDisallowed, v)
        end
    end

    return tDisallowed
end

// handle refresh requests
net.Receive("rl_loadout_requestrefresh", function(_, ply)
    if rlld.playerCooldowns.refresh[ply] then
        net.Start("rl_loadout_requestrefresh")
        net.Send(ply)
    else
        rlld.playerCooldowns.refresh[ply] = true
        timer.Simple(30, function()
            if IsValid(ply) then
                rlld.playerCooldowns.refresh[ply] = nil
            end
        end)

        ply:rlldCacheLoadouts()
    end
end)

net.Receive("rl_loadout_select", function(_, ply)
    local iSelect = net.ReadUInt(4)
    if rlld.playerCooldowns.selection[ply] then
        net.Start("rl_loadout_select")
            net.WriteUInt(1, 3)
        net.Send(ply)
    elseif iSelect > 10 or iSelect < 1 then
        net.Start("rl_loadout_select")
            net.WriteUInt(2, 3)
        net.Send(ply)
    else
        if iSelect > rl_g_iStandardLoadouts and not ply:CheckGroup(rl_g_sMinimumDonorRank) then
            net.Start("rl_loadout_select")
                net.WriteUInt(4, 3)
            net.Send(ply)
        else
            rlld.playerCooldowns.selection[ply] = true
            timer.Simple(5, function()
                if IsValid(ply) then
                    rlld.playerCooldowns.selection[ply] = nil
                end
            end)

            rlld.playerCache[ply].lastSelected = iSelect
            ply:rlldSaveFromCache()

            net.Start("rl_loadout_select")
                net.WriteUInt(3, 3)
                net.WriteUInt(iSelect, 6)
            net.Send(ply)
        end
    end
end)

// handle modify requests
net.Receive("rl_loadout_modify", function(len, ply)
    if rlld.playerCooldowns.modify[ply] then
        net.Start("rl_loadout_modify")
            net.WriteBool(false)
            net.WriteUInt(7, 6)
        net.Send(ply)
    else
        local iFailureCond = 0
        local tFailureInfo = {}
        local sCompressed = net.ReadData(len)
        local tData = string.Split(util.Decompress(sCompressed), ";")
        local iIndex = tonumber(table.remove(tData, 1))
        if iIndex > 10 then iFailureCond = 1 end
        local sTitle = string.JavascriptSafe(table.remove(tData, 1))
        if #sTitle == 0 then sTitle = "Default Loadout" end
        if #sTitle > 20 then iFailureCond = 2 end
        if #tData > 25 then iFailureCond = 3 end

        local sValidChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "
        local tValidChars = {}
        for k, v in pairs(string.Explode("", sValidChars)) do
            tValidChars[v] = true
        end
        for k, v in pairs(string.Explode("", sTitle)) do
            if not tValidChars[v] then
                iFailureCond = 8
            end
        end

        if not ply:CheckGroup(rl_g_sMinimumDonorRank) and iIndex > rl_g_iStandardLoadouts then
            iFailureCond = 9
        end

        rlld.playerCooldowns.modify[ply] = true
        timer.Simple(5, function()
            if not IsValid(ply) then return end
            rlld.playerCooldowns.modify[ply] = nil
        end)

        print("Received loadout modify request from " .. ply:Nick())

        if iFailureCond == 0 then
            local tCulmination = {
                index = iIndex,
                name = sTitle,
                weps = tData
            }
            local bFound = false

            for k, v in pairs(rlld.playerCache[ply].loadouts) do
                if v.index == iIndex then
                    bFound = true
                    break
                end
            end

            if bFound then

                tFailureInfo = ply:rlldAuditLoadout(tData)

                if type(tFailureInfo) == "table" then
                    if #tFailureInfo == 0 then
                        local bProblem = false
                        for k, v in pairs(tData) do
                            if not rl_g_tAllWeapons[v] then
                            //if not weapons.Get(v) then
                                bProblem = true
                                print("[RLLD] Problem with " .. ply:Nick() .. "'s loadout modification, weapon: " .. v)
                                break
                            end
                        end

                        tCulmination.weps = uniqueEntriesOnly(tCulmination.weps)

                        if not bProblem then
                            rlld.playerCache[ply].loadouts[iIndex] = tCulmination
                            ply:rlldSaveFromCache()

                            net.Start("rl_loadout_modify")
                                net.WriteBool(true)
                            net.Send(ply)

                            print("Completed modify request from " .. ply:Nick() .. ", changes saved")
                        else
                            iFailureCond = 10
                        end
                    else
                        iFailureCond = 5
                    end
                else
                    iFailureCond = 6
                end
            else
                iFailureCond = 4
            end
        end

        if iFailureCond != 0 then
            print("Denied modify request from " .. ply:Nick() .. ", case " .. iFailureCond)
            net.Start("rl_loadout_modify")
                net.WriteBool(false)
                net.WriteUInt(iFailureCond, 6)
                net.WriteTable(tFailureInfo)
            net.Send(ply)
        end
    end
end)

// FAILURE CODES:
// 1: invalid index
// 2: title too long
// 3: too many weps
// 4: no index matched
// 5: auditing problem
// 6: invalid audit return type
// 7: cooldown
// 8: invalid char in title
// 9: not the right rank
// 10: invalid weapon(s)

concommand.Add("rlr_testLocalStrip", function(ply, cmd, args)
    ply:StripWeapons()
end)

hook.Remove("PlayerGiveSWEP", "rll_test_table")
/*hook.Add("PlayerGiveSWEP", "rll_test_table", function(ply, wep, tab)
    local bFound = false
    for k, v in pairs(weapons.GetList()) do

        if v.ClassName == wep then

            bFound = true
            break

        end

    end

    if bFound then

        ply:ChatPrint("weapon found")
    else
        ply:ChatPrint("weapon not found", wep)

    end
end)*/

// give player correct weps on spawn
hook.Add("PlayerLoadout", "rl_loadout_give", function(ply)
    local tWepsToGive = generateBoilerplate(1).weps
    if rlld.playerCache[ply] then
        local tPlayerConfig = rlld.playerCache[ply]
        tWepsToGive = tPlayerConfig.loadouts[tPlayerConfig.lastSelected].weps

        local tDisallowedWeps = {}

        for k, v in pairs(tWepsToGive) do
            if ply:canAccess(v, "swep") then
                ply:Give(v)
            else
                table.insert(tDisallowedWeps, v)
            end
        end

        if tDisallowedWeps != {} and #tDisallowedWeps > 0 then
            net.Start("rl_loadout_denied")
                net.WriteTable(tDisallowedWeps)
            net.Send(ply)
        end

        /*local tDisallowedWeps = ply:rlldAuditLoadout(tWepsToGive)
        if tDisallowedWeps != {} and #tDisallowedWeps > 0 then
            for k, v in pairs(tDisallowedWeps) do
                table.RemoveByValue(tWepsToGive, v)
            end

            net.Start("rl_loadout_denied")
                net.WriteTable(tDisallowedWeps)
            net.Send(ply)
        end*/
    end

    ply:rlldGiveWepsList(tWepsToGive)

    return true
end)
