rlr = rlr or {}

rlr.config = {
    ["verifyFiles"] = {
        "swep.txt",
        "ent.txt",
        "prop.txt",
        "misc.txt",
        "tool.txt",
        "vehicle.txt",
    },

    ["propAlwaysBlock"] = {},
    ["propAlwaysAllow"] = {},
    ["propVolumeThreshold"] = 10000000, -- 10,000,000
    ["propDefaultLimit"] = GetConVar("sbox_maxprops"):GetInt(),
}

hook.Add("InitPostEntity", "rlr_init_config_proper", function()
    rlr.config.propVolumeThreshold = util.JSONToTable(file.Read("rl_restrictions/misc.txt", "DATA")).propVolumeThreshold
end)

local meta = FindMetaTable("Player")
function meta:canAccess(str, typeof)
    local requiredRank = rlr_config.roleIndex(rlr[typeof][str]) or -1
    local hasRank = rlr_config.roleIndex(self:GetUserGroup())

    if rlr_config.roleIndex(rlr[typeof][str]) == nil and rlr[typeof][str] != nil then
        for k, v in pairs(player.GetAll()) do
            for x, _ in pairs(rlr_config.roles.admin) do
                if x == v:GetUserGroup() then
                    net.Start("rl_needsReload")
                    net.Send(v)
                end
            end
        end
        net.Start("rl_restrictionInvalid")
        net.WriteString(str)
        net.Send(self)
        return "invalid"
    end

    if hasRank != nil and requiredRank != nil then
        if hasRank <= requiredRank or requiredRank == -1 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function rlr.sendWithTable(str, recipient, tab)
    net.Start("rl_" .. str)
    if tab != nil then net.WriteTable(tab) end
    net.Send(recipient)
end

function rlr.isPropTooBig(path)
    for k, v in pairs(rlr.config.propAlwaysBlock) do if v == path then /*print("always blocked");*/ return 2 end end
    for k, v in pairs(rlr.config.propAlwaysAllow) do if v == path then /*print("always allowed");*/ return false end end

    local prop = ents.Create("prop_physics")
    prop:SetModel(path)

    local mins = prop:LocalToWorld(prop:OBBMins())
    local maxs = prop:LocalToWorld(prop:OBBMaxs())

    prop:Remove()

    local width = maxs.x - mins.x   -- x
    local height = maxs.y - mins.y  -- y
    local depth = maxs.z - mins.z   -- z
    local volume = width * height * depth

    if volume != nil then
        if volume > rlr.config.propVolumeThreshold then
            return 1
        else
            return false
        end
    end
end

function rlr.verifyFileRankSync(tab, itype)
    local problems = {}
    for k, v in pairs(tab) do
        if rlr_config.roleIndex(rlr[itype][k]) == nil then
            table.insert(problems, 1, {k, v})
        end
    end

    if problems != {} then
        //problems.itype = itype
        /*net.Start("rl_invalidSync")
        net.WriteTable(problems)
        net.Broadcast()*/
        return problems
    end
end

function rlr.initFiles()
    if not file.IsDir("rl_restrictions", "DATA") then
        file.CreateDir("rl_restrictions")
    end

    for k, v in pairs(rlr.config.verifyFiles) do
        if not file.Exists("rl_restrictions/" .. v, "DATA") then
            MsgC(Color(255, 60, 60), "File ", v, " did not exist, creating\n")
            file.Write("rl_restrictions/" .. v, "")
        end
    end

    rlr.swep = util.JSONToTable(file.Read("rl_restrictions/swep.txt"))
    rlr.ent = util.JSONToTable(file.Read("rl_restrictions/ent.txt"))
    rlr.prop = util.JSONToTable(file.Read("rl_restrictions/prop.txt"))
    rlr.tool = util.JSONToTable(file.Read("rl_restrictions/tool.txt"))
    rlr.vehicle = util.JSONToTable(file.Read("rl_restrictions/vehicle.txt"))

    local file_problems = {}
    file_problems['swep'] = rlr.verifyFileRankSync(rlr.swep, "swep")
    file_problems['ent'] = rlr.verifyFileRankSync(rlr.ent, "ent")
    file_problems['prop'] = rlr.verifyFileRankSync(rlr.prop, "prop")
    file_problems['tool'] = rlr.verifyFileRankSync(rlr.tool, "tool")
    file_problems['vehicle'] = rlr.verifyFileRankSync(rlr.vehicle, "vehicle")

    local misc = util.JSONToTable(file.Read("rl_restrictions/misc.txt"))
    for k, v in pairs(misc) do
        rlr.config[k] = v
    end

    return file_problems
end

function rlr.getRankLimit(rank, itemtype)
    if !table.HasValue(rlr_config.roles.all, rank) then return nil end

    for k, v in pairs(rlr_config.limits) do
        local tabRank = rlr_config.roleIndex(k)
        local plyRank = rlr_config.roleIndex(rank)

        if plyRank <= tabRank then
            if v[itemtype] != nil then return v[itemtype] end
        end
    end
    //print(itemtype)
    return GetConVar("sbox_max" .. itemtype .. "s"):GetInt() or 0
end

hook.Add("PlayerSay", "rl_addChatCommand", function(ply, msg)
    if IsValid(ply) then
        if string.Replace(msg, " ", "") == "/restrict" then
            /*local info = {}
            info.ent = rlr.ent
            info.swep = rlr.swep
            info.prop = rlr.prop
            info.tool = rlr.tool
            info.vehicle = rlr.vehicle*/

            if rlr_config.roles.admin[ply:GetUserGroup()] == true then
                net.Start("rl_openMenu")
                net.Send(ply)
            else
                net.Start("rl_cannotOpenMenu")
                net.Send(ply)
            end
            return false
        /*elseif string.sub(string.Replace(msg, " ", ""), 1, 10) == "/threshold" then
            if rlr_config.roles.admin[ply:GetUserGroup()] == true then
                local args = string.Split(msg, " ")
                if args != nil and args[2] != nil then
                    local amt = tonumber(string.Replace(args[2], " ", ""))

                    if amt != nil then
                        rlr.config.propVolumeThreshold = amt
                        local content = util.JSONToTable(file.Read("rl_restrictions/misc.txt", "DATA"))
                        content.propVolumeThreshold = amt
                        file.Write("rl_restrictions/misc.txt", util.TableToJSON(content, true))
                        rlr.sendWithTable("thresholdSuccess", ply, {
                            ["amount"] = amt,
                        })
                    else
                        rlr.sendWithTable("thresholdInvalid", ply)
                    end
                else
                    rlr.sendWithTable("thresholdInvalid", ply)
                end
            else
                rlr.sendWithTable("thresholdNotAdmin", ply)
            end
            return false*/
        elseif string.Replace(msg, " ", "") == "/rlr_reloadfiles" then
            if rlr_config.roles.reload[ply:GetUserGroup()] == true then
                local file_problems = rlr.initFiles()
                for k, v in pairs(file_problems) do
                    if #file_problems[k] < 1 then
                        file_problems[k] = nil
                    end
                end
                rlr.sendWithTable("adminReloadedFiles", player.GetAll(), {ply})
                rlr.sendWithTable("toAdminReportConflicts", ply, file_problems)
            end
            return false
        end
    end
end)

/*hook.Add("PlayerSpawnProp", "rl_blockBigProps", function(ply, model)
    if rlr.isPropTooBig(model) == 1 then
        rlr.sendWithTable("cannotSpawnProp", ply)
        return false
    elseif rlr.isPropTooBig(model) == 2 then
        rlr.sendWithTable("cannotSpawnProp", ply, {["special"] = true})
    end
end)*/

local function dumpTabToPly(ply)
    local rank = ply:GetUserGroup()
    //if rlr_config.roles.admin[rank] == true then
    if true then
        local info = {}
        info.ent = rlr.ent
        info.swep = rlr.swep
        info.prop = rlr.prop
        info.tool = rlr.tool
        info.vehicle = rlr.vehicle
        rlr.sendWithTable("dumpTable", ply, info)
    end
end
hook.Add("PlayerInitialSpawn", "rl_sendTableToAdminsOnJoin", dumpTabToPly)
net.Receive("rl_requestRedump", function(len, ply)
    if rlr_config.roles.admin[ply:GetUserGroup()] == true then
        dumpTabToPly(ply)
        if net.ReadBit() == 1 then
            net.Start("rl_openMenu")
            net.Send(ply)
        end
    end
end)

hook.Add("InitPostEntity", "rl_cacheRestrictions", function()
    rlr.initFiles()
end)

concommand.Add("rlr_reloadfiles", function(ply, cmd, args)
    if rlr_config.roles.reload[ply:GetUserGroup()] == true then
        local file_problems = rlr.initFiles()
        for k, v in pairs(file_problems) do
            if #file_problems[k] < 1 then
                file_problems[k] = nil
            end
        end
        rlr.sendWithTable("adminReloadedFiles", player.GetAll(), {ply})
        rlr.sendWithTable("toAdminReportConflicts", ply, file_problems)
    end
end)

concommand.Add("rlr_openmenu", function(ply, cmd, args)
    local info = {}
    info.ent = rlr.ent
    info.swep = rlr.swep
    info.prop = rlr.prop
    info.tool = rlr.tool
    info.vehicle = rlr.vehicle

    if rlr_config.roles.admin[ply:GetUserGroup()] == true then
        rlr.sendWithTable("openMenu", ply, info)
    else
        net.Start("rl_cannotOpenMenu")
        net.Send(ply)
    end
end)

hook.Add("PlayerLoadout", "rl_giveLoadoutWeps", function(ply)
    /*for k, v in pairs(rlr_config.loadout) do
        local userRole = rlr_config.roleIndex(ply:GetUserGroup())
        local sampleRole = rlr_config.roleIndex(k)

        if userRole != nil && sampleRole != nil then
            if userRole <= sampleRole then
                for _, x in pairs(v) do ply:Give(x) end
            end
        end
    end*/
end)
