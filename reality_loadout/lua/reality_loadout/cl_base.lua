rll      = rll or {}
rll.data = rll.data or {}
rll.theme = {
    ["rnd"] = 8,
    //["accent"] = Color(200, 255, 0),
    ["accent"] = Color(48, 179, 255),
    ["white"] = Color(255, 255, 255),
    ["darkgrey"] = Color(50, 50, 50),
    ["medgrey"] = Color(65, 65, 65),
    ["lightgrey"] = Color(160, 160, 160),
    ["green"] = Color(100, 255, 100),
    ["red"] = Color(255, 100, 100),
}

function rlld_g_lighten(col, amt)
    local conv = {ColorToHSL(col)}
    conv[3] = math.Clamp(conv[3] + amt, 0, 1)
    return HSLToColor(unpack(conv))
end

function rlld_g_canAccessSwep(class)
    if not LocalPlayer() then return false end

    local requiredRank = rlr_config.roleIndex(rlr.swep[class]) or -1
    local hasRank = rlr_config.roleIndex(LocalPlayer():GetUserGroup())

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

rll.theme.accentlight = rlld_g_lighten(rll.theme.accent, 0.2)

//rll.theme.accentlight = {ColorToHSL(rll.theme.accent)}
//rll.theme.accentlight[3] = math.Clamp(rll.theme.accentlight[3] + 0.2, 0, 1)
//rll.theme.accentlight = HSLToColor(unpack(rll.theme.accentlight))

local function pntc(sColored, ...)
    chat.AddText(rll.theme.accent, sColored, rll.theme.white, unpack(arg))
end

local function printWeaponsList(list)
    MsgC(rll.theme.accent, "--- x ---\n[RLLD] Error Report\n", rll.theme.white, "The following weapons are restricted:\n")
    for k, v in pairs(list) do
        MsgC(rll.theme.accent, " + ", rll.theme.white, v, "\n")
    end
end

net.Receive("rl_loadout_denied", function()
    local tDeniedWeps = net.ReadTable()
    chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "One or more weapons in your loadout are restricted from your rank. Check the console for more information.")
    printWeaponsList(tDeniedWeps)
end)

net.Receive("rl_loadout_dump", function(len)
    local sCompressed = net.ReadData(len / 8)
    local sJson = util.Decompress(sCompressed)
    local tData = util.JSONToTable(sJson)
    rll.data = tData

    chat.AddText(rll.theme.accent, "Success! ", rll.theme.white, "Loadouts received/reloaded.")
    hook.Run("rlld_refresh_success")
end)

net.Receive("rl_loadout_modify", function()
    local bSuccess = net.ReadBool()
    if not bSuccess then
        rll.modifQueue = nil
        timer.Remove("rll_queuetimeout")
        surface.PlaySound("buttons/weapon_cant_buy.wav")

        local iFailCode = net.ReadUInt(6)
        if iFailCode == 1 then -- invalid index
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Invalid loadout index (<=10). Your changes have not been saved.")
        elseif iFailCode == 2 then -- title too long
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Title is too long (<20 chars). Your changes have not been saved.")
        elseif iFailCode == 3 then -- too many weps
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Too many weapons in loadout (<=25). Your changes have not been saved.")
        elseif iFailCode == 4 then
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Search by index failed. Your changes have not been saved.")
        elseif iFailCode == 5 then
            local tInvalidWeps = net.ReadTable()
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "One or more proposed weapons are restricted from your rank. Check the console for more information. Your changes have not been saved.")
            printWeaponsList(tInvalidWeps)
            MsgC(rll.theme.accent, "--- x ---\n", rll.theme.white)
        elseif iFailCode == 6 then
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Problem when supplying weapon table serverside. Your changes have not been saved.")
        elseif iFailCode == 7 then
            chat.AddText(rll.theme.accent, "Calm it! ", rll.theme.white, "Plase wait 5s between saving changes to loadouts. Your changes have not been saved.")
        elseif iFailCode == 8 then
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Your loadout title contains illegal characters. Your changes have not been saved.")
        elseif iFailCode == 9 then
            chat.AddText(rll.theme.accent, "Woah! ", rll.theme.white, "Only donors can use that loadout. Your changes have not been saved.")
        elseif iFailCode == 10 then
            chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "One or more of your weapons are invalid. Your changes have not been saved.")
        end
    else
        for k, v in pairs(rll.data.loadouts) do
            if v.index == rll.modifQueue.index then
                rll.data.loadouts[k] = rll.modifQueue
                rll.modifQueue = nil
                timer.Remove("rll_queuetimeout")
                chat.AddText(rll.theme.accent, "Success! ", rll.theme.white, "The loadout was modified and saved successfully.")
                if rlld_g_MenuFrame then rlld_g_MenuFrame:SetPage('home') end
                surface.PlaySound("buttons/bell1.wav")
                break
            end
        end
    end
end)

net.Receive("rl_loadout_select", function()
    local iFailCode = net.ReadUInt(3)
    if iFailCode == 1 then -- cooldown
        chat.AddText(rll.theme.accent, "Woah there! ", rll.theme.white, "Please wait 5s between selecting loadouts.")
    elseif iFailCode == 2 then -- invalid index
        chat.AddText(rll.theme.accent, "Error! ", rll.theme.white, "Invalid loadout index (<=10).")
    elseif iFailCode == 3 then -- success
        local iSwitchedLoadout = net.ReadUInt(6)
        local iPreviousLoadout = rll.data.lastSelected
        rll.data.lastSelected = iSwitchedLoadout
        chat.AddText(rll.theme.accent, "Nice! ", rll.theme.white, "Your loadout has been changed. Respawn to get your guns.")
        hook.Run("rlld_select_success", iPreviousLoadout, iSwitchedLoadout)
        surface.PlaySound("buttons/button24.wav")
    elseif iFailCode == 4 then -- donor loadout
        chat.AddText(rll.theme.accent, "Hold on! ", rll.theme.white, "That loadout is only for donors.")
    end
end)

concommand.Add("rlld_refresh", function()
    net.Start("rl_loadout_requestrefresh")
    net.SendToServer()
end)

concommand.Add("rlld_display", function(_, _, args)
    if args[1] == nil then PrintTable(rll.data.loadouts) else

        if #args < 1 then return print("Please supply a loadout index!") end
        local iIndex = tonumber(args[1])
        if iIndex > 10 then return print("Please supply a valid loadout index") end
        local tLoadout = rll.data.loadouts[iIndex]

        PrintTable(tLoadout)
    end
end)

concommand.Add("rlld_select", function(_, _, args)
    if #args < 1 then return print("You currently have loadout " .. rll.data.lastSelected .. " selected") end
    local iIndex = tonumber(args[1])
    if iIndex > 10 or iIndex < 1 then return print("Please supply a valid loadout index") end

    net.Start("rl_loadout_select")
        net.WriteUInt(iIndex, 4)
    net.SendToServer()
end)

concommand.Add("rlld_modify", function(_, _, args)
    if rll.modifQueue != nil then return print("You already have a loadout modification pending!") end
    if #args != 3 then return print("Not enough arguments!") end -- index, title, contents
    local iIndex = tonumber(args[1])
    if iIndex > 10 then return print("Invalid index! (<10)") end
    local sTitle = string.JavascriptSafe(args[2])
    if #sTitle > 20 then return print("Title is too long! (<20 chars)") end
    if #sTitle == 0 then return print("Title must contain at least 1 valid character!") end
    local tContents = string.Split(args[3], ";")
    if #tContents > 25 then return print("Too many weapons! (<=25)") end

    local sCompressed = util.Compress(table.concat(args, ";"))
    net.Start("rl_loadout_modify")
        net.WriteData(sCompressed, #sCompressed)
    net.SendToServer()

    rll.modifQueue = {
        index = iIndex,
        name = sTitle,
        weps = tContents,
    }
    timer.Create("rll_queuetimeout", 30, 1, function()
        rll.modifQueue = nil
        chat.AddText(rll.theme.accent, "Sorry, ", rll.theme.white, "your loadout modify request timed out. Please try again or contact staff.")
    end)

    chat.AddText(rll.theme.accent, "Whoosh! ", rll.theme.white, "The modify request was sent to the server.")
end)

net.Receive("rl_loadout_requestrefresh", function()
    chat.AddText(rll.theme.accent, "Woah there! ", rll.theme.white, "Please wait 30s between refreshes.")
end)
