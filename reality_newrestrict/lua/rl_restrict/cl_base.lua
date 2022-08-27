rlr = rlr or {}

net.Receive("rl_cannotSpawnProp", function()
    local tab = net.ReadTable()
    local concat = "too large"
    if tab != nil then
        if tab.special == true then
            concat = "blocked"
        end
    end
    chat.AddText(Color(255, 255, 255), "This prop is ", Color(48, 179, 255), concat, Color(255, 255, 255), ". Please contact a manager if you believe this is incorrect.")
end)

net.Receive("rl_thresholdNotAdmin", function()
    chat.AddText(Color(255, 255, 255), "You must be a ", Color(48, 179, 255), "manager", Color(255, 255, 255), " or above to execute this command.")
end)

net.Receive("rl_thresholdInvalid", function()
    chat.AddText(Color(255, 255, 255), "The argument supplied was ", Color(48, 179, 255), "invalid", Color(255, 255, 255), ".")
end)

net.Receive("rl_thresholdSuccess", function()
    local tab = net.ReadTable()
    chat.AddText(Color(255, 255, 255), "You have changed the threshold to ", Color(48, 179, 255), tostring(tab.amount), Color(255, 255, 255), ".")
end)

net.Receive("rl_needsReload", function()
    local cl1 = Color(255, 0, 0)
    local cl2 = Color(255, 80, 80)
    chat.AddText(cl2, "!!! [ADM] Restrictions are not synced correctly! Check console/menu for more details.")
end)

net.Receive("rl_restrictionInvalid", function()
    local cl1 = Color(255, 80, 80)
    local cl2 = Color(255, 180, 180)
    chat.AddText(cl2, "!!! The restriction for this item (", cl1, net.ReadString(), cl2, ") is invalid. All online admins have been messaged.")
end)

/*net.Receive("rl_invalidSync", function()
    local problems = net.ReadTable()
    local itype = problems.itype
    problems.itype = nil

    local cl1 = Color(255, 80, 80)
    local cl2 = Color(255, 180, 180)
    MsgC(cl1, ">[RLR] - An error has occurred! Problems with the following \"", cl2, itype, cl1, "\" table:\n")
    for k, v in pairs(problems) do
        MsgC(cl2, v[1], cl1, " has unassigned role ", cl2, v[2], "\n")
    end
    MsgC(cl1, ">[RLR] ERROR END\n\n")

    chat.AddText(cl2, "!!! Restrictions table ", cl1, itype, cl2, " has an invalid role sync! Check console for more details.")
end)*/

net.Receive("rl_toAdminReportConflicts", function()
    local file_problems = net.ReadTable()
    local cl1 = Color(255, 80, 80)
    local cl2 = Color(255, 180, 180)

    chat.AddText(cl1, "When you reloaded the files, some errors occured. Check your console for details.")
    MsgC(cl1, " [RLR] An error has occurred! Details following.\n")
    for k, v in pairs(file_problems) do
        MsgC(cl1, "   These errors occured within the \"", cl2, k, cl1, "\" category:\n")
        for l, x in pairs(v) do
            MsgC("     ", cl2, x[1], cl1, " is assigned to group ", cl2, x[2], cl1, " which does not exist.\n")
        end
    end
    MsgC(cl1, " [RLR] End of error reporting.\n")
end)

net.Receive("rl_cannotOpenMenu",  function()
    chat.AddText(Color(255, 255, 255), "You do not have the appropriate permissions to open the restrictions menu.")
end)

net.Receive("rl_denySpawn", function()
    local tab = net.ReadTable()
    local concat = { " to rank ", Color(48, 179, 255), rlr_config.roleDisplay(tab.rank), Color(255, 255, 255), " and above." }
    if tab.rank == "*" then concat = { " from ", Color(48, 179, 255), "all ranks", Color(255, 255, 255), "." } end

    if tab.special == nil then
        chat.AddText(Color(255, 255, 255), "This item is restricted", unpack(concat))
    elseif tab.special == 1 then
        chat.AddText(Color(255, 255, 255), "This tool is restricted", unpack(concat))
    end
end)

net.Receive("rl_denyPickup", function()
    local rank = net.ReadString()

    local concat = { " to rank ", Color(48, 179, 255), rlr_config.roleDisplay(rank), Color(255, 255, 255), " and above." }
    if rank == "*" then concat = { " from ", Color(48, 179, 255), "all ranks", Color(255, 255, 255), "." } end

    chat.AddText(Color(255, 255, 255), "You have tried to equip/pickup a weapon that is restricted", unpack(concat))
end)
