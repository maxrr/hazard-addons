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

RAFK_ENUM_DUMP = 0
RAFK_ENUM_UPDATE = 1

// all time in seconds
local iAFKMarkTime = 600
local iAFKKickTime = 1800

local tPrintReplacements = {
    ["away"] = {
        Color(255, 100, 100),
        "You have gone AFK. You will be kicked in " .. tostring(math.Round((iAFKKickTime - iAFKMarkTime) / 60), 2) .. " minute(s).",
        " has gone AFK.",
    },
    ["back"] = {
        Color(100, 255, 100),
        "You have returned from being AFK.",
        " has returned.",
    },
}

if SERVER then

	local tNoKickWhitelist = {
		['76561198006327894'] = true,
        ['76561198351674996'] = true,
		['76561198099066547'] = true,
	}

    local function updateStatus(ply, afk)
        if IsValid(ply) then
            net.Start("rafk_net")
                net.WriteUInt(RAFK_ENUM_UPDATE, 4)
                net.WriteEntity(ply)
                net.WriteBool(afk)
            net.Broadcast()
        end
    end

    util.AddNetworkString("rafk_net")
    hook.Add("PlayerAuthed", "rafk_init", function(ply) -- on player spawn, dump all afk players to new player (for scoreboard)
        ply.rafk_lastaction = CurTime()
        ply.rafk_bool = false

        local tTemp = {}
        for k, v in pairs(player.GetHumans()) do
            if IsValid(v) then
                if v.rafk_bool != nil and v.rafk_lastaction != nil then
                    table.insert(tTemp, {v, v.rafk_bool, v.rafk_lastaction})
                end
            end
        end
        net.Start("rafk_net")
            net.WriteUInt(RAFK_ENUM_DUMP, 4)
            net.WriteTable(tTemp)
        net.Send(ply)
    end)

    local function resetPlayerStatus(ply)
        if ply.rafk_bool then
            updateStatus(ply, false)
        end
        ply.rafk_lastaction = CurTime()
        ply.rafk_bool = false
    end

    hook.Add("KeyPress", "rafk_trackkeystroke", resetPlayerStatus)
    hook.Add("PlayerSay", "rafk_trackchat", resetPlayerStatus)
    hook.Add("PlayerSwitchWeapon", "rafk_trackswap", resetPlayerStatus)
	hook.Add("PlayerDisconnected", "rafk_cleanondisconnect", function(ply)
		ply.rafk_lastaction = nil
		ply.rafk_bool = nil
	end)

    local function pollPlayersForAfk()
        local iTime = CurTime()
        for k, v in pairs(player.GetHumans()) do
            if IsValid(v) and v.rafk_bool != nil and v.rafk_lastaction != nil and tNoKickWhitelist[v:SteamID64()] != true and v:TimeConnected() > iAFKMarkTime then
                if iTime >= v.rafk_lastaction + iAFKMarkTime and not v.rafk_bool then
                    v.rafk_bool = true
                    updateStatus(v, true)
                end
                if iTime >= v.rafk_lastaction + iAFKKickTime then
                    local sKickReason = "You were AFK for over " .. tostring(iAFKKickTime / 60) .. " minutes."

					-- log our actions
					print('[RAFK] ' .. v:Nick() .. ' was kicked for being AFK.')
					if ulx then
						ulx.fancyLogAdmin( v, true, "#A has been kicked for being idle longer than " .. tostring(iAFKKickTime / 60) .. " minutes." )
					end

                    v:Kick(sKickReason)
                end
            end
        end
    end

    timer.Create("rafk_poll", 3, 0, pollPlayersForAfk)
else
    // CLIENT START
    if not ConVarExists("rafk_cl_ding") then
        CreateClientConVar("rafk_cl_ding", "0", true)
    end

    local bShouldPing = GetConVar("rafk_cl_ding"):GetBool()
    timer.Create("rafk_cl_ding_create", 5, 0, function()
        bShouldPing = GetConVar("rafk_cl_ding"):GetBool()
    end)

    local mTriangleMat = Material("reality_smallscripts/warningsign.png")

    local tTriangleBaseVertices = {
        { x = 0, y = 0 },
        { x = 20, y = 0 },
        { x = 10, y = 30 },
    }

    local function drawWarningSign(relX, relY, col)
        if relX >= 0 and relY >= 0 then
            surface.SetDrawColor(158, 119, 0)
            surface.SetMaterial(mTriangleMat)
            surface.DrawTexturedRect(relX, relY, 14, 42)
        end
    end

    local function pl(s, a) return a != 1 and (s .. "s") or (s) end

    local function translateTimeText(time)

        time = math.floor(time)

        local min = math.floor(time / 60)
        local sec = math.Round(time % 60)

        if time >= 60 then
            if sec > 0 then
                return (min .. pl(" minute", min) .. " and " .. sec .. pl(" second", sec))
            else
                return (min .. pl(" minute", min))
            end
        else
            return (sec .. pl(" second", sec))
        end
    end


    local iTextW = 400
    local iPanelW = iTextW
    local iPanelH = 60

    local iPanelXCurrent = -iPanelW
    local iPanelXShould = -iPanelW

    local iPanelSideW = 40

    local iPaddingOffset = iPanelSideW + 8*3

    local iTimeRemaining = 0

    /*timer.Create("rafk_noshowverify", 1, 0, function()
        if not LocalPlayer().rafk_bool then
            iPanelXShould = -iPanelW
        end
    end)*/

    local sLastDisplayed = ""

    local function carryOutTextStuff(str)
        surface.SetFont("HUDNumberDisplay")
        iTextW, _ = surface.GetTextSize(str)
        iPanelW = iTextW + iPaddingOffset

        return str
    end

    local function refreshTextWidth(timeleft)

        if not LocalPlayer().rafk_bool then

            return carryOutTextStuff(sLastDisplayed)

        end

        local sDisplayedString = "You will be AFK kicked in " .. translateTimeText(timeleft - CurTime()) .. "."
        sLastDisplayed = sDisplayedString

        //surface.SetFont("HUDNumberDisplay")
        //iTextW, _ = surface.GetTextSize(sDisplayedString)

        //iPanelW = iTextW + iPaddingOffset

        return carryOutTextStuff(sDisplayedString)

    end

    local function displayWarning(timeleft)

        iTimeRemaining = CurTime() + timeleft

        refreshTextWidth(iTimeRemaining)

        //iPanelXShould = iTextW + iPaddingOffset
        iPanelXShould = 0

    end

    hook.Add("HUDPaint", "rafk_warning", function()

        local sDisplayedString = refreshTextWidth(iTimeRemaining)

        iPanelXCurrent = Lerp(FrameTime() * 10, iPanelXCurrent, iPanelXShould)

        iPanelW = iTextW + iPaddingOffset

        /*if iPanelXCurrent - iPanelW != 0 and LocalPlayer().rafk_bool then
            iPanelXCurrent = iPanelW
        end*/

        draw.RoundedBoxEx(8, iPanelXCurrent, ScrH() / 2 - iPanelH / 2, iPanelW, iPanelH, Color(255, 224, 130), false, true, false, true)
        draw.RoundedBoxEx(8, iPanelXCurrent, ScrH() / 2 - iPanelH / 2, iPanelSideW, iPanelH, Color(255, 212, 079), false, true, false, true)

        draw.SimpleText(sDisplayedString, "HUDNumberDisplay", iPanelXCurrent + iPanelW - 12, ScrH() / 2, Color(158, 119, 0), 2, 1)

        drawWarningSign(iPanelXCurrent + (iPanelSideW - 14) / 2, ScrH() / 2 - 42 / 2, Color(30, 30, 30))

    end)

    net.Receive("rafk_net", function()
        local iMode = net.ReadUInt(4)
        if iMode == RAFK_ENUM_DUMP then

            local tTemp = net.ReadTable()

            for k, v in pairs(tTemp) do

                v[1].rafk_bool = v[2]
                v[1].rafk_duration = v[3]

            end

        elseif iMode == RAFK_ENUM_UPDATE then

            local pPlayer = net.ReadEntity()
            local bAssign = net.ReadBool()

            pPlayer.rafk_bool = bAssign
            pPlayer.rafk_duration = CurTime()

                  bAssign = bAssign and "away" or "back"

            local bIsSelf = pPlayer == LocalPlayer()

            local tPrintArguments = {}
            local cPrintColor = bIsSelf and tPrintReplacements[bAssign][1] or Color(130, 130, 130)
            local tContent = bIsSelf and ({tPrintReplacements[bAssign][2]}) or ({pPlayer, tPrintReplacements[bAssign][3]})
            table.Add(tPrintArguments, {cPrintColor})
            table.Add(tPrintArguments, tContent)

            chat.AddText(unpack(tPrintArguments))

            if bIsSelf then

                if LocalPlayer().rafk_bool then

                    displayWarning(iAFKKickTime - iAFKMarkTime)

                    if bShouldPing then surface.PlaySound("npc/turret_floor/ping.wav") end

                    timer.Create("rafk_warn", 1, 0, function()
                        if bShouldPing then surface.PlaySound("npc/turret_floor/ping.wav") end
                    end)

                else

                    iPanelXShould = -iPanelW

                    timer.Remove("rafk_warn")

                end

            end

        else
            ErrorNoHalt("Reality's Anti-AFK: invalid mode set for rafk_net netmessage!")
        end
    end)
end
