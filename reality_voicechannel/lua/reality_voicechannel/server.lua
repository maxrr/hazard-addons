util.AddNetworkString("rlvc_setchannel")
util.AddNetworkString("rlvc_dumpToNewlyConnected")
util.AddNetworkString("rlvc_newlyConnected")

RLVC.ply = RLVC.ply or {}
local meta = FindMetaTable("Player")
function meta:RLVCSetChannel(channel)
    if RLVC.establishedChannels[channel] == true then
        RLVC.ply[self:SteamID64()] = channel
        return channel
    else
        return false
    end
end
function meta:RLVCGetChannel()
    local retrieved = RLVC.ply[self:SteamID64()]
    if retrieved != nil then
        if RLVC.establishedChannels[retrieved] == true then
            return retrieved
        else
            return self:RLVCSetChannel(RLVC.defaultChannel)
        end
    else
        return self:RLVCSetChannel(RLVC.defaultChannel)
    end
end

net.Receive("rlvc_setchannel", function(_, ply)
    local channel = ply:RLVCGetChannel()

    if channel == "global" then ply:RLVCSetChannel("proximity")
    elseif channel == "proximity" then ply:RLVCSetChannel("global")
    else ErrorNoHalt("RLVC player " .. ply:SteamID64() .. " channel invalid while toggling") end

    net.Start("rlvc_setchannel")
        net.WriteEntity(ply)
        if channel == "global" then net.WriteBit(true)
        elseif channel == "proximity" then net.WriteBit(false)
        else ErrorNoHalt("RLVC channel invalid") end
    net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "rlvc_init", function(ply)
    ply:RLVCSetChannel(RLVC.defaultChannel)

    local tempPly = table.Copy(player.GetAll())
    table.RemoveByValue(tempPly, ply)

    local info = {}
    for k, v in pairs(tempPly) do
		table.insert(info, {v:SteamID64(), v:RLVCGetChannel()})
    end

    net.Start("rlvc_dumpToNewlyConnected")
        net.WriteTable(info)
    net.Send(ply)

    net.Start("rlvc_newlyConnected")
        net.WriteEntity(ply)
    net.Broadcast()
end)

hook.Add("PlayerCanHearPlayersVoice", "rlvc_actual", function(listener, talker)
    if talker.ulx_gagged then return false end
    local ply1ch = listener:RLVCGetChannel()
    local ply2ch = talker:RLVCGetChannel()

    /*if ply1ch == ply2ch then
        if ply1ch == "global" then
            return true, false
        elseif ply1ch == "proximity" then
            if listener:GetPos():DistToSqr(talker:GetPos()) <= 250000 then
                return true, true
            end
        else
            ErrorNoHalt("PCHPV hook -> invalid channel")
        end
    else
        return false
    end*/

    if ply1ch == "global" and ply2ch == "global" then
        return true, false
    elseif ply1ch == "proximity" or ply2ch == "proximity" then
        if listener:GetPos():DistToSqr(talker:GetPos()) <= 562500 then
            return true, true
        else
            return false
        end
    else
        return false
    end
end)

hook.Add("ShutDown", "rlvc_closeHook", function()
    hook.Remove("PlayerCanHearPlayersVoice", "rlvc_actual")
end)

resource.AddFile("materials/rl_voicehannels_mats/global.png")
