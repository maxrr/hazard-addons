karma = karma or {}

local config = {}
config.cooldown = 28800 -- seconds in a day

net.Receive("rhud_rate", function(len, ply)
    local netinfo = net.ReadTable()
    local rateid = netinfo.id -- person being rated
    local plyid = ply:SteamID64() -- person that is rating

    if plyid != rateid then 
        if ply:IsBot() then plyid = "bot" .. ply:UniqueID() end

        local should = true
        local info
        for k, v in pairs(karma[plyid]["cooldown"]) do
            if v["id"] == rateid then
                should = false
                info = v
                if v["time"] < os.time() then
                    should = true
                end
                break
            end
        end

        if should == false then
            local ninfo = {}
            ninfo.success = false
            ninfo.id = rateid
            ninfo.callerid = plyid
            ninfo.cooldown = info["time"] - os.time()

            net.Start("rhud_rate")
            net.WriteTable(ninfo)
            net.Send(ply)
        else
            local cooldown = os.time() + config.cooldown
            local temp = {
                ["id"] = rateid,
                ["time"] = cooldown,
                ["positive"] = netinfo.positive,
            }

            for k, v in pairs(karma[plyid]["cooldown"]) do
                if v["id"] == rateid then
                    table.remove(karma[plyid]["cooldown"], k)
                end
            end
            table.insert(karma[plyid]["cooldown"], 1, temp)
            if netinfo.positive == true then
                karma[plyid]["plus"] = karma[plyid]["plus"] + 1
            else
                karma[plyid]["minus"] = karma[plyid]["minus"] + 1
            end
            file.Write("rhud_karma/" .. plyid .. ".txt", util.TableToJSON(karma[plyid], true))

            local ninfo = {}
            ninfo.success = true
            ninfo.id = rateid
            ninfo.callerid = plyid
            ninfo.positive = netinfo.positive
            ninfo.cooldown = temp

            net.Start("rhud_rate")
            net.WriteTable(ninfo)
            net.Broadcast()
        end
    end
end)

local function rhud_karma_init(ply)
    local id = tostring(ply:SteamID64())
    if ply:IsBot() then id = "bot" .. ply:UniqueID() end -- steamid64 does not work with bot, this is the workaround

    local path = "rhud_karma/" .. id .. ".txt"
    local boilerplate = {
        ["id"] = id,
        ["plus"] = 0, -- positive ratings
        ["minus"] = 0, -- negative ratings
        ["cooldown"] = {},
    }

    if !file.Exists(path, "DATA") then
        file.Write(path, util.TableToJSON(boilerplate, true))
    end

    local json = util.JSONToTable(file.Read(path))
    karma[id] = json

    net.Start("rhud_karma-init")
    net.WriteTable(json)
    net.Broadcast()

    net.Start("rhud_karma-sendall")
    net.WriteTable(karma)
    net.Send(ply)
end

net.Receive("rhud_karma-init", function(len, ply)
    rhud_karma_init(ply)
end)

hook.Add("PlayerInitialSpawn", "rhud_karma-load-alternate", function(ply)
    if ply:IsBot() then rhud_karma_init(ply) end
end)

hook.Add("InitPostEntity", "rhud_karma-load", function()
    if !file.IsDir("rhud_karma", "DATA") then
        file.CreateDir("rhud_karma")
    end
end)
