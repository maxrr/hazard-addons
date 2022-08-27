AUTOPROMOTE_RANKTABLE = { // ALL TIMES IN HOURS
    veteran = 336,
    addict = 168,
    dedicated = 72,
    trusted = 24,
    member = 3,
    user = 0,
}
// ply:CheckGroup(k)
local AUTOPROMOTE_TIMEDRANKS = {}

for k, v in pairs(AUTOPROMOTE_RANKTABLE) do
    table.insert(AUTOPROMOTE_TIMEDRANKS, {name = k, hrs = v})
end

table.sort(AUTOPROMOTE_TIMEDRANKS, function(a, b)
    return a.hrs < b.hrs
end)

AUTOPROMOTE_RANKTABLE[-1] = -1
AUTOPROMOTE_GREATESTTIME = 0

for k, v in pairs(AUTOPROMOTE_RANKTABLE) do AUTOPROMOTE_GREATESTTIME = math.max(AUTOPROMOTE_GREATESTTIME, v) end
for k, v in pairs(ULib.ucl.groups) do AUTOPROMOTE_RANKTABLE[k] = AUTOPROMOTE_RANKTABLE[k] or -1 end

if SERVER then

    util.AddNetworkString("autopromote_rankup")

    local function pollPlayer(ply)

        if IsValid(ply) then

            local sGroup = ply:GetUserGroup()

            if AUTOPROMOTE_RANKTABLE[sGroup] and ply:GetNWBool("IsPlayerFullyLoaded", false) == true then

                if AUTOPROMOTE_RANKTABLE[sGroup] != -1 then // skip if not in an eligible group

                    local iTime = ply:GetUTimeTotalTime() // returns in seconds
                    iTime = iTime / 3600 // turn into hours

                    local sLastGroup = -1

                    for k, v in pairs(AUTOPROMOTE_RANKTABLE) do // loop through and get highest pt rank
                        if iTime >= v and v > AUTOPROMOTE_RANKTABLE[sLastGroup] and v != -1 then
                            sLastGroup = k
                        end
                    end

                    if sLastGroup != nil and sLastGroup != -1 then // validity check

                        if AUTOPROMOTE_RANKTABLE[sLastGroup] > AUTOPROMOTE_RANKTABLE[sGroup] then // skip if planning on demoting

                            if not IsValid(ply) or not ply:IsConnected() or ply:IsBot() then return end

                            RunConsoleCommand("ulx", "adduserid", ply:SteamID(), sLastGroup)

                            net.Start("autopromote_rankup")
                                net.WriteEntity(ply)
                                net.WriteString(sLastGroup)
                            net.Broadcast()

                        end

                    end

                end

            end

        end

    end

    concommand.Add("autopromote_refresh", function(ply, cmd, args)
        if IsValid(ply) then
            pollPlayer(ply)
        end
    end)

    timer.Create("autopromote_periodicallypoll", 10, 0, function()
        for k, v in pairs(player.GetHumans()) do
            pollPlayer(v)
        end
    end)

else

    local function pl(s, a) return a != 1 and (s .. "s") or (s) end

    AUTOPROMOTE_DERMAINIT = AUTOPROMOTE_DERMAINIT or false
    AUTOPROMOTE_SHOWTABS = false

    local iPlaytimeHours = 0
    local mCheckMaterial = Material("reality_smallscripts/checkmark.png")

    local function initDerma(contextMenuPanel)

        if contextMenuPanel == nil then return end
        contextMenuPanel:SetSize(ScrW(), ScrH())

        AUTOPROMOTE_DERMACHILDREN = {}

        AUTOPROMOTE_DERMAPANEL = vgui.Create("DFrame", contextMenuPanel):TDLib():ClearPaint()//:Background(Color(255, 0, 0, 10))
        AUTOPROMOTE_DERMAPANEL:SetSize(32, 600) // NOTE: RESET TO 32 BEFORE UPLOAD
        AUTOPROMOTE_DERMAPANEL:SetPos(ScrW() - AUTOPROMOTE_DERMAPANEL:GetWide() - 10, ScrH() - AUTOPROMOTE_DERMAPANEL:GetTall() - 80)
        AUTOPROMOTE_DERMAPANEL:SetDraggable(false)
        AUTOPROMOTE_DERMAPANEL:SetSizable(false)
        AUTOPROMOTE_DERMAPANEL:SetTitle("")
        AUTOPROMOTE_DERMAPANEL:ShowCloseButton(false)

        local iParentH = AUTOPROMOTE_DERMAPANEL:GetTall() - 50
        local iParentOffset = (AUTOPROMOTE_DERMAPANEL:GetTall() - iParentH) / 2

        local iPlaytimeRelative = math.Clamp(iPlaytimeHours, 0, AUTOPROMOTE_GREATESTTIME) / AUTOPROMOTE_GREATESTTIME * iParentH

        local iProgressPadding = 6

        local iProgressBarHeight = AUTOPROMOTE_DERMAPANEL:GetTall() / #AUTOPROMOTE_TIMEDRANKS - 25 - iProgressPadding


        local tProgressAttributes = {}
        for i = 0, #AUTOPROMOTE_TIMEDRANKS - 2 do

            local iBackgroundPanelY = i * (iProgressBarHeight + 35 + iProgressPadding) + 28 + iProgressPadding / 2
            local iLastTimeHrs = AUTOPROMOTE_TIMEDRANKS[i + 1].hrs
            local iDiffTimeHrs = AUTOPROMOTE_TIMEDRANKS[i + 2].hrs - iLastTimeHrs

            tProgressAttributes[i] = {
                iBackgroundPanelY = iBackgroundPanelY,
                iLastTimeHrs = iLastTimeHrs,
                iDiffTimeHrs = iDiffTimeHrs,
            }

        end


        AUTOPROMOTE_DERMAPANEL:On("Paint", function(s, w, h)
            //draw.RoundedBox(4, 32/2 - 4, 25, 8, h - 50, Color(30, 30, 30))
            //draw.RoundedBox(4, 32/2 - 4, iParentH - iPlaytimeRelative + 25, 8, iPlaytimeRelative, Color(255, 255, 255))

            for i = 0, #AUTOPROMOTE_TIMEDRANKS - 2 do

                local iBackgroundPanelY = tProgressAttributes[i].iBackgroundPanelY

                draw.RoundedBox(4, 8, iBackgroundPanelY, 16, iProgressBarHeight, Color(30, 30, 30, 255))

            end

            for i = 0, #AUTOPROMOTE_TIMEDRANKS - 2 do

                local iBackgroundPanelY, iLastTimeHrs, iDiffTimeHrs = tProgressAttributes[i].iBackgroundPanelY, tProgressAttributes[i].iLastTimeHrs, tProgressAttributes[i].iDiffTimeHrs

                local iRelativeHeight = math.Clamp((iPlaytimeHours - iLastTimeHrs) / iDiffTimeHrs, 0, 1) * (iProgressBarHeight - 4)

                local iPanelY = iParentH - i * (iProgressBarHeight + 41) - 76 - iProgressPadding / 2
                iPanelY = iPanelY + (iProgressBarHeight - iRelativeHeight) - 2

                //surface.SetDrawColor(30, 30, 30, 255)
                //draw.NoTexture()
                //surface.DrawRect(8, iBackgroundPanelY, 16, iProgressBarHeight)
                //draw.RoundedBox(32, 8, iBackgroundPanelY, 16, iProgressBarHeight, Color(30, 30, 30, 255))

                draw.RoundedBox(math.min(4, iRelativeHeight), 10, iPanelY, 12, iRelativeHeight, Color(255, 255, 255))

                //draw.SimpleText(math.min(iRelativeHeight, 4), "DermaDefaultBold", 20, iPanelY + iProgressBarHeight / 2, Color(255, 255, 255), 0, 1)

            end
        end)

        local iIncCount = 1

        for l, x in pairs(AUTOPROMOTE_TIMEDRANKS) do

            local k, v = x.name, x.hrs

            if v != -1 and v != 0 then

                iIncCount = iIncCount + 1

                //local iRelative = v / AUTOPROMOTE_GREATESTTIME * iParentH
                local iRelative = (iIncCount / (table.Count(AUTOPROMOTE_TIMEDRANKS) - 1)) * iParentH - 100

                if ULib.ucl.groups[k] then
                    local tGroupLinkedTeam = ULib.ucl.groups[k].team
                    local cTeamColor = Color(tGroupLinkedTeam.color_red, tGroupLinkedTeam.color_green, tGroupLinkedTeam.color_blue)

                    local panel = vgui.Create("DPanel", contextMenuPanel):TDLib():ClearPaint()//:Background(Color(0, 255, 0, 80))
                    panel:SetSize(32, 32)
                    panel:SetMouseInputEnabled(true)

                    table.insert(AUTOPROMOTE_DERMACHILDREN, panel)

                    local iPanelX, iPanelY = AUTOPROMOTE_DERMAPANEL:GetPos()

                    panel.w_should = 32
                    panel.w_current = 32

                    panel.y_current = iPanelY + iParentH - (iRelative + iParentOffset / 2 - panel:GetTall() / 1.5) - 4

                    local sRankName = string.upper(tGroupLinkedTeam.name)
                    local sTimeRequired = v .. " HOURS"
                    if v % 24 == 0 then sTimeRequired = string.upper(v / 24 .. pl(" day", v / 24)) end
                    if v % 168 == 0 then sTimeRequired = string.upper(v / 168 .. pl(" week", v / 168)) end
                    if v < 1 then sTimeRequired = string.upper(v * 60 .. pl(" minute", v * 60)) end

                    surface.SetFont("HUDNumberDisplay")
                    local iTotalTextWidth, _ = surface.GetTextSize(sRankName .. sTimeRequired) + 8*5
                    local iTimeTextWidth, _ = surface.GetTextSize(sTimeRequired) + 32

                    local cSelectedColor = Color(30, 30, 30)

                    local tTimeColors = {Color(30, 30, 30), Color(255, 255, 255)}
                    //if bCompleted then tTimeColors = table.Reverse(tTimeColors) end

                    panel:MoveToFront()
                    panel:SetText("")
                    panel.Paint = function(s, w, h)
                        if not AUTOPROMOTE_SHOWTABS then return end
                        local bCompleted = iPlaytimeHours >= v

                        s:SetPos(iPanelX - panel.w_current + 32, panel.y_current)

                        draw.RoundedBox(8, 0, 0, w, h, cTeamColor)
                        draw.RoundedBox(8, 4, 4, 24, 24, cSelectedColor)
                        if bCompleted then

                            //draw.RoundedBox(8, 6, 6, 20, 20, Color(255, 255, 255))
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(mCheckMaterial)
                            //surface.DrawTexturedRect(w / 2 - 8, h / 2 - 8, 16, 16)
                            surface.DrawTexturedRect(8, 8, 16, 16)

                        end

                        s.w_current = Lerp(RealFrameTime() * 10, s.w_current, s.w_should)
                        s:SetSize(s.w_current, 32)
                        if vgui.GetHoveredPanel() == s then
                            s.w_should = iTotalTextWidth + 32
                        else
                            s.w_should = 32
                        end

                        draw.RoundedBoxEx(8, 40 + iTotalTextWidth - iTimeTextWidth, 0, iTimeTextWidth - 8, 32, tTimeColors[1], false, true, false, true)
                        draw.SimpleText(sRankName, "HUDNumberDisplay", 36, h/2, Color(30, 30, 30), 0, 1)
                        draw.SimpleText(sTimeRequired, "HUDNumberDisplay", 36 + iTotalTextWidth - iTimeTextWidth + 16, h/2, tTimeColors[2], 0, 1)
                    end
                end
            end

        end

        //AUTOPROMOTE_DERMAPANEL:MoveToFront()

    end

    if AUTOPROMOTE_DERMAINIT then
        if AUTOPROMOTE_DERMAPANEL != nil then
            AUTOPROMOTE_DERMAPANEL:Remove()
            for k, v in pairs(AUTOPROMOTE_DERMACHILDREN) do
                v:Remove()
            end
        end
        initDerma(g_ContextMenu)
    end

    local bContextMenuCreated = false
    local bInitPostEntity = false

    local function initDermaOnSuccess()
        if bContextMenuCreated and bInitPostEntity and not AUTOPROMOTE_DERMAINIT then

            iPlaytimeHours = math.floor(LocalPlayer():GetUTimeTotalTime() / 3600)

            initDerma(g_ContextMenu)
            AUTOPROMOTE_DERMAINIT = true

        end
    end

    hook.Add("ContextMenuCreated", "autopromote_initderma", function(parentPanel)
        bContextMenuCreated = true
        initDermaOnSuccess()
    end)

    hook.Add("InitPostEntity", "autopromote_entityinit", function()
        bInitPostEntity = true
        initDermaOnSuccess()
    end)

    hook.Add("OnContextMenuOpen", "autopromote_drawbuts", function()
        AUTOPROMOTE_SHOWTABS = true
        timer.Create("autopromote_refreshplaytime", 0.5, 0, function()
            iPlaytimeHours = LocalPlayer():GetUTimeTotalTime() / 3600
        end)
    end)

    hook.Add("OnContextMenuClose", "autopromote_hideuts", function()
        AUTOPROMOTE_SHOWTABS = false
        timer.Remove("autopromote_refreshplaytime")
    end)

    net.Receive("autopromote_rankup", function()

        local ply = net.ReadEntity()
        local sGroup = net.ReadString()

        local cTextColor = Color(255, 255, 255)

        if IsValid(ply) then
            if ply:IsPlayer() then
                if sGroup != nil then
                    if ULib.ucl.groups[sGroup] != nil then

                        local tGroupLinkedTeam = ULib.ucl.groups[sGroup].team
                        local cTeamColor = Color(tGroupLinkedTeam.color_red, tGroupLinkedTeam.color_green, tGroupLinkedTeam.color_blue)

                        local iPlayTime = math.floor(ply:GetUTimeTotalTime() / 3600) // convert to hrs

                        chat.AddText(cTeamColor, ply:Nick(), cTextColor, " has been awarded the rank of ", cTeamColor, tGroupLinkedTeam.name, cTextColor, " for reaching ", cTeamColor, tostring(iPlayTime), cTextColor, " hours of playtime.")

                    end
                end
            end
        end

    end)

end
