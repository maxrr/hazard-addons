/*
 * This addon was checked for any sensitive or revealing information
 * that could be potentially harmful towards our users. If you, the 
 * reader, see ANY potentially sensitive, revealing, or harmful information
 * or data in this addon or anywhere else in this repository, please
 * immediately reach out through a pull request or to our staff members.
 *
 * In addition, please remember that these addons were made over the
 * course of several years, and have altered significantly compared
 * to their original state. They very well may not work in the presence
 * of other community addons, and likely will not function properly
 * unless loaded alongside other addons in this collection. We will
 * provide zero support, guidance, or troubleshooting to anyone having
 * difficulty with these addons, so please use at your own risk. 
*/

AddCSLuaFile("autorun/client/rsig_cl.lua")

local TitleInfo = TitleInfo or {}

include("sv_config.lua")

util.AddNetworkString("rsig_update")
util.AddNetworkString("rsig_cl_change")
util.AddNetworkString("rsig_cl_menu")
util.AddNetworkString("rsig_msg_update")
util.AddNetworkString("rsig_msg_reload")
util.AddNetworkString("rsig_msg_noperm")
util.AddNetworkString("rsig_config_upd")
util.AddNetworkString("rsig_admin_reset")

local function rsig_loadtitle(ply)
    local info = {}
    info.title = ply:GetPData("rsig_title", "Newbie")
    info.color = Color(ply:GetPData("rsig_color_red", 255), ply:GetPData("rsig_color_green", 255), ply:GetPData("rsig_color_blue", 255))
    info.rainbow = ply:GetPData("rsig_rainbow_bool", "false")

    net.Start("rsig_update")
    net.WriteTable(info)
    net.WriteString(ply:SteamID64())
    net.Broadcast()

    TitleInfo[ply:SteamID64()] = info
end

hook.Add("PlayerInitialSpawn", "rsig_loadtitle", function(ply)
    net.Start("rsig_config_upd")
    net.WriteTable(rsig)
    net.Send(ply)

    timer.Simple(3, function()
        rsig_loadtitle(ply)
        for k, v in pairs(player.GetAll()) do
            local info = {}
            info.title = v:GetPData("rsig_title", "Newbie")
            info.color = Color(v:GetPData("rsig_color_red", 255), v:GetPData("rsig_color_green", 255), v:GetPData("rsig_color_blue", 255))
            info.rainbow = v:GetPData("rsig_rainbow_bool", "false")

            net.Start("rsig_update")
            net.WriteTable(info)
            net.WriteString(v:SteamID64())
            net.Send(ply)
        end
    end)
end)

timer.Create("rsig_updateconfig", 10, 0, function()
    for k, v in pairs(player.GetAll()) do
        net.Start("rsig_config_upd")
        net.WriteTable(rsig)
        net.Send(v)
    end
end)

net.Receive("rsig_cl_change", function(len, ply)
    local info = net.ReadTable()
    ply:SetPData("rsig_title", info.title)
    ply:SetPData("rsig_color_red", info.color["r"])
    ply:SetPData("rsig_color_green", info.color["g"])
    ply:SetPData("rsig_color_blue", info.color["b"])

    local f = 0

    for k, v in pairs(rsig.advanced) do
        if ply:GetUserGroup() == v then
            f = 1
            break
        end
    end

    if f == 1 then
        ply:SetPData("rsig_rainbow_bool", info.rainbow)
    else
        ply:SetPData("rsig_rainbow_bool", false)
    end

    rsig_loadtitle(ply)
end)

local function saveTitleNPC(ply)
    local newpos = {}
    local map = game.GetMap()

    for k, v in pairs(ents.FindByClass("titles_npc")) do
        local pos = v:GetPos()
        local ang = v:GetAngles()

        newpos[k] = {}
        newpos[k].pos = pos
        newpos[k].ang = ang
    end

    if not file.IsDir("rsig", "DATA") then file.CreateDir("rsig") end
    if not file.Exists("rsig/" .. map .. ".txt", "DATA") then file.Write("rsig/" .. map .. ".txt", "") else rsig_pos = util.JSONToTable(file.Read("rsig/" .. map .. ".txt", false)) end

    file.Write("rsig/" .. map .. ".txt", util.TableToJSON(newpos, true))

    net.Start("rsig_msg_update")
    net.WriteEntity(ply)
    net.Broadcast()
end

local function loadTitleNPC()
    local map = game.GetMap()
    if !file.Exists("rsig/" .. map .. ".txt", "DATA") then return end
    local positions = util.JSONToTable(file.Read("rsig/" .. map .. ".txt", false))

    for k, v in pairs(ents.FindByClass("titles_npc")) do
        v:Remove()
    end

    for k, v in pairs(positions) do
        local ent = ents.Create("titles_npc")
        ent:Spawn()
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
    end
end

hook.Add("InitPostEntity", "addNPCSOnStart", function()
    timer.Simple(3, function()
        loadTitleNPC()
    end)
end)

concommand.Add("titles_load", function(ply)
    local f = 0
    for k, v in pairs(rsig.usergroups) do
        if ply:GetUserGroup() == v then
            f = 1
            loadTitleNPC()
            net.Start("rsig_msg_reload")
            net.Broadcast()
            break
        end
    end
    if f == 0 then
        net.Start("rsig_msg_noperm")
        net.Send(ply)
    end
end)

concommand.Add("titles_save", function(ply, cmd)
    local f = 0
    for k, v in pairs(rsig.usergroups) do
        if ply:GetUserGroup() == v then
            f = 1
            saveTitleNPC(ply)
            break
        end
    end
    if f == 0 then
        net.Start("rsig_msg_noperm")
        net.Send(ply)
    end
end)

concommand.Add("titles_reset", function(ply, cmd, args)
    local f = 0
    for k, v in pairs(rsig.usergroups) do
        if ply:GetUserGroup() == v then
            f = 1
            local nf = 0
            for _, x in pairs(player.GetAll()) do
                if string.find(string.lower(x:Nick()), string.lower(args[1])) != nil then
                    nf = 1
                    local info = {}
                    info.nick = x:Nick()
                    info.team = x:Team()
                    x:SetPData("rsig_title", "Newbie")
                    x:SetPData("rsig_color_red", 255)
                    x:SetPData("rsig_color_green", 255)
                    x:SetPData("rsig_color_blue", 255)
                    x:SetPData("rsig_rainbow_bool", "false")

                    rsig_loadtitle(x)
                    net.Start("rsig_admin_reset")
                    net.WriteTable(info)
                    net.Broadcast()
                end
            end
            if nf == 0 then
                print("[RSIG] Player not found.")
            end
        end
    end
    if f == 0 then
        net.Start("rsig_msg_noperm")
        net.Send(ply)
    end
end)
