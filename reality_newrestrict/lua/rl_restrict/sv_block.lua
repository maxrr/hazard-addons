rlr.recentDeny = {}

local meta = FindMetaTable("Player")
function meta:sendDeny(rank, special)
    local info = {}
    info.rank = rank
    if special != nil then info.special = special end

    net.Start("rl_denySpawn")
    net.WriteTable(info)
    net.Send(self)
end

local function blockUsage(ply, itemtype, thing, chkLimit, countMod)
    if chkLimit == nil  || type(chkLimit) != "boolean" then chkLimit = true end
    if countMod == nil  || type(countMod) != "number" then countMod = 0 end

    local result = ply:canAccess(thing, itemtype)
    if result == false then
        ply:sendDeny(rlr[itemtype][thing])
        return false
    end
    if result == "invalid" then
        return false
    end

    if itemtype == "ent" then itemtype = "sent" end

    if chkLimit == true then
        //print(chkLimit)
        //print(itemtype)
        //print(thing)
        //print(ply)
        local limit = rlr.getRankLimit(ply:GetUserGroup(), itemtype)
        if limit != nil then
            local count = ply:GetCount(itemtype .. "s") + countMod
            if count >= limit then
                ply:LimitHit(itemtype .. "s")
                return false
            elseif GetConVar("sbox_max" .. itemtype .. "s"):GetInt() != nil then        // overwrite sandbox limits, ours is greater
                if GetConVar("sbox_max" .. itemtype .. "s"):GetInt() < limit then
                    return true
                end
            end
        end
    end
end

hook.Remove("PlayerSpawnProp",    "rlr_blockPropFunc")
hook.Remove("CanTool",            "rlr_blockToolFunc")
hook.Remove("PlayerSpawnVehicle", "rlr_blockVehicleFunc")
hook.Remove("PlayerSpawnSENT",    "rlr_blockSWEPFunc")
hook.Remove("PlayerGiveSWEP",     "rlr_blockSWEPFunc")
hook.Remove("PlayerSpawnSWEP",    "rlr_blockSWEPSpwFunc")

hook.Add("PlayerSpawnProp",       "rlr_blockPropFunc",     function(ply, prop)         return blockUsage(ply, "prop",     prop)                 end)
hook.Add("CanTool",               "rlr_blockToolFunc",     function(ply, _, tool)      return blockUsage(ply, "tool",     tool,       false)    end)
hook.Add("PlayerSpawnVehicle",    "rlr_blockVehicleFunc",  function(ply, _, vehicle)   return blockUsage(ply, "vehicle",  vehicle)              end)
hook.Add("PlayerSpawnSENT",       "rlr_blockEntFunc",      function(ply, ent)          return blockUsage(ply, "ent",      ent,        nil, -1)  end)
hook.Add("PlayerGiveSWEP",        "rlr_blockSWEPFunc",     function(ply, weapon)       return blockUsage(ply, "swep",     weapon,     false)    end)
hook.Add("PlayerSpawnSWEP",       "rlr_blockSWEPSpwFunc",  function(ply, weapon)       return blockUsage(ply, "swep",     weapon,     false)    end)

hook.Add("PlayerSpawnNPC", "rlr_setNPCLimit", function(ply)
    local limit = rlr.getRankLimit(ply:GetUserGroup(), "npc")
    if limit != nil then
        local count = ply:GetCount("npcs")
        if count >= limit then
            ply:LimitHit("npcs")
            return false
        elseif GetConVar("sbox_maxnpcs"):GetInt() != nil then        // overwrite sandbox limits, ours is greater
            //print(GetConVar("sbox_maxnpcs"):GetInt())
            if GetConVar("sbox_maxnpcs"):GetInt() < limit then
                //print("passing again")
                return true
            end
        end
    end
end)

timer.Simple(0.1, function()

    print("yes")

    if AdvDupe2 then
        hook.Add("PlayerSpawnEntity", "rlr_watchAdvDupe2", function(ply, EntTable)
            print(ply:Nick())
            PrintTable(EntTable)
        end)
    end

end)

hook.Add("PlayerCanPickupWeapon", "rlr_blockSWEPPickup", function(ply, wep)
    local weapon = wep:GetClass()
    local result = ply:canAccess(weapon, "swep")
    if result == false then
        wep:Remove()

        if rlr.recentDeny[tostring(ply:SteamID64())] == nil then
            rlr.recentDeny[tostring(ply:SteamID64())] = true
            timer.Simple(0.1, function()
                rlr.recentDeny[tostring(ply:SteamID64())] = nil
            end)

            net.Start("rl_denyPickup")
            net.WriteString(rlr.swep[weapon])
            net.Send(ply)
        end
        return false
    end
    if result == "invalid" then
        return false
    end
end)
// ^^ uncomment if you dont want pickups abusable
