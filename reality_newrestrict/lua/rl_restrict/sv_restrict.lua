function rlr_restrict(sItem, sRank, sType)
    //print("restricting")
    //print("  item: " .. sItem)
    //print("  rank: " .. sRank)
    //print("  type: " .. sType)
    local validTypes = rlr_config.easyKeyTable({"swep", "ent", "prop", "tool", "vehicle"})
    if validTypes[sType] == true then
        rlr[sType][sItem] = sRank
        file.Write("rl_restrictions/" .. sType .. ".txt", util.TableToJSON(rlr[sType], true))
    end
end

function rlr_unrestrict(sItem, sType)
    local validTypes = rlr_config.easyKeyTable({"swep", "ent", "prop", "tool", "vehicle"})
    if validTypes[sType] == true then
        rlr[sType][sItem] = nil
        file.Write("rl_restrictions/" .. sType .. ".txt", util.TableToJSON(rlr[sType], true))
    end
end

net.Receive("rl_modifyRestriction", function(len, ply)
    if rlr_config.roles.admin[ply:GetUserGroup()] == true then
        local info = net.ReadTable()
        local item = info.item
        local rank = info.rank
        rlr[info.type][item] = rank
        file.Write("rl_restrictions/" .. info.type .. ".txt", util.TableToJSON(rlr[info.type], true))

        info.change = "modify"
        info.person = ply

        for k, v in pairs(player.GetAll()) do
            if rlr_config.roles.admin[v:GetUserGroup()] == true then
                net.Start("rl_confirmRestriction")
                net.WriteTable(info)
                net.Send(v)
            end
        end
    end
end)

net.Receive("rl_addRestriction", function(len, ply)
    if rlr_config.roles.admin[ply:GetUserGroup()] == true then
        local info = net.ReadTable()
        local item = info.item
        local rank = info.rank
        rlr[info.type][item] = rank
        file.Write("rl_restrictions/" .. info.type .. ".txt", util.TableToJSON(rlr[info.type], true))

        info.change = "add"
        info.person = ply

        for k, v in pairs(player.GetAll()) do
            if rlr_config.roles.admin[v:GetUserGroup()] == true then
                net.Start("rl_confirmRestriction")
                net.WriteTable(info)
                net.Send(v)
            end
        end
    end
end)

net.Receive("rl_deleteRestriction", function(len, ply)
    if rlr_config.roles.admin[ply:GetUserGroup()] == true then
        local info = net.ReadTable()
        local item = info.item
        rlr[info.type][item] = nil
        file.Write("rl_restrictions/" .. info.type .. ".txt", util.TableToJSON(rlr[info.type], true))

        info.change = "delete"
        info.person = ply

        for k, v in pairs(player.GetAll()) do
            if rlr_config.roles.admin[v:GetUserGroup()] == true then
                net.Start("rl_confirmRestriction")
                net.WriteTable(info)
                net.Send(v)
            end
        end
    end
end)
