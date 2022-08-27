rhud_sb = rhud_sb or {}
karma = karma or {}
// update comment
local config = {}
config.cooldown = 28800
config.maxnamewidth = 180

local needsupdate = false
local width = 700
local height = ScrH() * 0.95
local init = false

rhud_sb.managementRanks = {
    "owner",
    "ownerassistant",
    "superadmin",
}

rhud_sb.adminRanks = {
	"admin",
    "moderator",
    "helper",
}

rhud_sb.donorRanks = {
    "premiumplus",
    "premium",
}

-- make our new hidden ranks!
rhud_sb.hiddenTeams = {
	"Hidden",
}

rhud_sb.allTeams = {
	"Developer",
	"Community Manager",
	"Manager",
	"Administrator",
	"Moderator",
    "Helper",
	"Premium+",
	"Premium",
	"Veteran",
	"Addict",
	"Dedicated",
	"Regular",
	"Member",
	"Guest",
    "Unassigned",
}

rhud_sb.subMenu = {
    "Unmute",
    "Copy ID",
    "Open Profile",
}

local hints = {
    "Want to talk with people about anything? Check out our discord!",
    "Our server can only run with the contributions of generous players. Thanks!",
    "Looking for a higher prop limit? Donators get them increased!",
    "Don't forget to favorite us in the Legacy Browser in order to find us again quickly!",
    "You can mute a player by clicking on the speaker icon next to their name.",
    "Left click a player for more options!",
    "Click on a player's profile picture to go to their profile!",
}

//hook.Add("InitPostEntity", "rhud_karma-load", function()
//    net.Start("rhud_karma-init")
//    net.SendToServer()
//end)

//net.Receive("rhud_karma-init", function(len)
//    local json = net.ReadTable()
//    local id = tostring(json.id)
//    karma[id] = json
//end)

//net.Receive("rhud_karma-sendall", function(len)
//    local info = net.ReadTable()
//    karma = info
//end)

local adminMaterial = Material("icon16/shield.png")
local donorMaterial = Material("icon16/heart.png")
local managementMaterial = Material("icon16/wand.png")
local friendMaterial = Material("icon16/user_green.png")
local blockedMaterial = Material("icon16/flag_red.png")
local loadingMaterial = Material("icon16/disconnect.png")
local websiteMaterial = Material("icon16/world.png")
local discordMaterial = Material("icon16/user_comment.png")
local donateMaterial = Material("icon16/coins.png")
local forumsMaterial = Material("icon16/group_link.png")
local pingMaterial = Material("icon16/connect.png")
local playersMaterial = Material("icon16/user_gray.png")
local addonsMaterial = Material("icon16/brick_add.png")
local afkMaterial = Material("icon16/status_away.png")

local skullMaterial = Material("r_hud/skull.png")
local mutedMaterial = Material("r_hud/mic_muted_small.png")
local unmutedMaterial = Material("r_hud/mic_small.png")
local upMaterial = Material("r_hud/uparrow.png")
local downMaterial = Material("r_hud/downarrow.png")

local function shortenName(name)
    local tw, th = draw.SimpleText(name, "HUDLargerNumberDisplay", 0, 0, Color(0, 0, 0, 0))
    if tw > config.maxnamewidth then
        name = string.sub(name, 0, string.len(name) - 4) .. "..."
        return shortenName(name)
    else
        return name, tw
    end
end

/*local function shortenKarma(karma)
    if karma > 1000000 then
        return math.Round(karma / 1000000, 2) .. "m"
    elseif karma > 1000 then
        //return math.Round(karma / 1000, 2) .. "k"
        return math.Round(karma / 1000, 2) .. "k"
    else
        return karma
    end
end*/

local function timeToStr( time )
	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	--return string.format( "%02iw %id %02ih %02im %02is", w, d, h, m, s )
	if w > 0 then
		return string.format("%02iw %id %02ih %02im %02is", w, d, h, m, s)
	elseif d > 0 then
		return string.format("%id %02ih %02im %02is", d, h, m, s)
	elseif h > 0 then
		return string.format("%02ih %02im %02is", h, m, s)
	elseif m > 0 then
		return string.format("%02im %02is", m, s)
	end
end

function rhud_sb:show()
    local cl = {
        Color(48, 179, 255),
        Color(47, 23, 63),
        Color(0, 49, 51),
        Color(35, 63, 43), -- manager
        Color(60, 60, 60),
        Color(255, 255, 255),
    }

    local maximumheight = 38
    local tootall = false

    local teamTableToUse = table.Copy(rhud_sb.allTeams)

    if (LocalPlayer():IsAdmin()) then

        teamTableToUse = table.Merge(teamTableToUse, rhud_sb.hiddenTeams)

    end

    for k, v in pairs(team.GetAllTeams()) do
        maximumheight = maximumheight + 22
        for _, x in pairs(team.GetPlayers(k)) do
            maximumheight = maximumheight + 39
        end
    end
    if maximumheight > ScrH() * 0.95 then maximumheight = ScrH() * 0.95; tootall = true end

    local hint = table.Random(hints)

    local frame = vgui.Create("DFrame")
    frame:SetSize(width, maximumheight - 1)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetTitle("")
    frame:SetKeyBoardInputEnabled(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 10, w, h - 20, Color(20, 20, 20, 255))
        draw.RoundedBox(8, 0, 0, w, 25, cl[1])
        draw.RoundedBox(0, 0, 15, w, 10, cl[1])
        draw.RoundedBox(8, 0, h - 25, w, 25, cl[1])
        draw.RoundedBox(0, 0, h - 25, w, 10, cl[1])
        draw.RoundedBox(0, 0, 25, w, 20, Color(45, 45, 45))
        //draw.SimpleText("HAZARD", "HUDLargeNumberDisplay", w / 2, 5, Color(20, 20, 20), 1, 0)
        draw.SimpleText("Hazard Gaming • hgaming.net", "HUDSmallNumberDisplay", w / 2, 5, Color(20, 20, 20), 1, 0)
        draw.SimpleText(hint, "HUDSmallNumberDisplay", w / 2, h - 20, Color(20, 20, 20), 1, 0)
        draw.SimpleText(#player.GetAll() .. "/" .. game.MaxPlayers(), "HUDNumberDisplay", 25, 4, Color(20, 20, 20))

        local baradjustment = 0
        if tootall then baradjustment = -20 end
        draw.SimpleText("PING", "HUDScoreboard", w - 40 + baradjustment, 30, Color(255, 255, 255), 1, 0)
        draw.SimpleText("PLAYTIME", "HUDScoreboard", w - 170 + baradjustment, 30, Color(255, 255, 255), 1, 0)
        draw.SimpleText("KILLS /  DEATHS", "HUDScoreboard", w - 330 + baradjustment, 30, Color(255, 255, 255), 1, 0)

        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(playersMaterial)
        surface.DrawTexturedRect(7, 4, 16, 16)
    end

    if !IsValid(LocalPlayer()) then return frame:Remove() end
    if LocalPlayer():SteamID64() == nil then return frame:Remove() end

    local addonsbutton = vgui.Create("DButton", frame)
    addonsbutton:SetSize(16, 16)
    addonsbutton:SetPos(frame:GetWide() - 103, 4)
    addonsbutton:SetText("")
    addonsbutton:SetTooltip("Download our addons!")
    addonsbutton.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(addonsMaterial)
        surface.DrawTexturedRect(0, 0, 16, 16)
    end
    addonsbutton.DoClick = function()
        frame:Remove()
        gui.OpenURL("https://hgaming.net/addons")
    end

    local websitebutton = vgui.Create("DButton", frame)
    websitebutton:SetSize(16, 16)
    websitebutton:SetPos(frame:GetWide() - 83, 4)
    websitebutton:SetText("")
    websitebutton:SetTooltip("Visit our website!")
    websitebutton.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(websiteMaterial)
        surface.DrawTexturedRect(0, 0, 16, 16)
    end
    websitebutton.DoClick = function()
        frame:Remove()
        gui.OpenURL("https://hgaming.net")
    end

    local forumsbutton = vgui.Create("DButton", frame)
    forumsbutton:SetSize(16, 16)
    forumsbutton:SetPos(frame:GetWide() - 63, 4)
    forumsbutton:SetText("")
    forumsbutton:SetTooltip("Visit our forums!")
    forumsbutton.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(forumsMaterial)
        surface.DrawTexturedRect(0, 0, 16, 16)
    end
    forumsbutton.DoClick = function()
        frame:Remove()
        gui.OpenURL("https://hgaming.net/forums/")
    end

    local donatebutton = vgui.Create("DButton", frame)
    donatebutton:SetSize(16, 16)
    donatebutton:SetPos(frame:GetWide() - 43, 4)
    donatebutton:SetText("")
    donatebutton:SetTooltip("Donate and support the server!")
    donatebutton.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(donateMaterial)
        surface.DrawTexturedRect(0, 0, 16, 16)
    end
    donatebutton.DoClick = function()
        frame:Remove()
        gui.OpenURL("https://hgaming.net/donate.html")
    end

    local discordbutton = vgui.Create("DButton", frame)
    discordbutton:SetSize(16, 16)
    discordbutton:SetPos(frame:GetWide() - 23, 4)
    discordbutton:SetText("")
    discordbutton:SetTooltip("Join our discord!")
    discordbutton.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(discordMaterial)
        surface.DrawTexturedRect(0, 0, 16, 16)
    end
    discordbutton.DoClick = function()
        frame:Remove()
        gui.OpenURL("https://hgaming.net/discord")
    end

    local ppanel = vgui.Create("DScrollPanel", frame)
    ppanel:SetSize(width - 5, maximumheight - 80)
    ppanel:SetPos(0, 50)
    ppanel.Paint = function(self, w, h)
        //draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 255))
    end

    local sbar = ppanel:GetVBar()
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 10, w, h - 20, Color(40, 40, 40))
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(w / 2 - 2, 0, 0, w, h, cl[1])
        draw.RoundedBox(0, 0, h / 2 + 1, w, h / 2, cl[1])
    end
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(w / 2 - 2, 0, 0, w, h, cl[1])
        draw.RoundedBox(0, 0, 0, w, h / 2, cl[1])
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, cl[1])
    end

    local totalheight = 0
    for _, teamName in pairs(rhud_sb.allTeams) do
        local playerCache = {}
		local teamPlayers = 0
		local teamInfo
		local teamIndex
		for k, v in pairs(player.GetAll()) do
			if team.GetName(v:Team()) == teamName then
				if teamInfo == nil then
					for tempindex, tempinfo in pairs(team.GetAllTeams()) do
						if tempindex == v:Team() then
							teamInfo = tempinfo
							teamIndex = tempindex
						end
					end
				end
				table.insert(playerCache, 1, v)
				teamPlayers = teamPlayers + 1
			end
		end

        table.sort(playerCache, function(a, b)
            return a:Nick() < b:Nick()
        end)
        if teamPlayers > 0 then
            local teampanel = vgui.Create("DPanel", ppanel)
            teampanel:SetSize(ppanel:GetWide(), 22 + teamPlayers * 39)
            if tootall then teampanel:SetSize(ppanel:GetWide() - 20, 24 + teamPlayers * 39) end
            teampanel:SetPos(5, totalheight)
            teampanel.Paint = function(self, w, h)
                //draw.RoundedBox(0, 0, 0, w, h, Color(255, 120, 0))
                local tw, th = draw.SimpleText(string.upper(team.GetName(teamIndex)), "HUDNameDisplay", 5, 4, Color(20, 20, 20))
                draw.RoundedBox(4, 1, 2, tw + 9, 18, team.GetColor(teamIndex))
                draw.SimpleText(string.upper(team.GetName(teamIndex)), "HUDNameDisplay", 5, 4, Color(20, 20, 20))
            end
            totalheight = totalheight + (25 + teamPlayers * 39) + 3

            for k, ply in pairs(playerCache) do

                local id = ply:SteamID64()
                if id != nil then id = tostring(id) end
                local doneloading = (IsValid(ply) and (id != nil or ply:IsBot())/* and karma[id] != nil and karma[id]["plus"] != nil and karma[id]["minus"] != nil*/)
                local isadmin = false
                local ismanager = false
                local isdonor = false
                local isfriend = false
                local isblocked = false
                local cooldowninfo
                local karmawidth
                local symbolAdjust = 0
                local plykarma
                local karmadj
                local nick, nickwidth = shortenName(ply:Nick())
                //local nick, nickwidth = shortenName("ThisNameIsMuchTooLongHelloIt'sMe")
                local starttime = os.time()

                //if LocalPlayer():SteamID64() == nil then return frame:Remove() end

				/*if LocalPlayer():SteamID64() != nil then
					for k, v in pairs(karma[LocalPlayer():SteamID64()]["cooldown"]) do
						if v["id"] == id then
							cooldowninfo = v
						end
					end
				end*/

                local timestring = timeToStr(ply:GetUTimeTotalTime())

                for _, v in pairs(rhud_sb.adminRanks) do if v == ply:GetUserGroup() then isadmin = "This player is a staff member."; symbolAdjust = symbolAdjust + 19; break end end
                for _, v in pairs(rhud_sb.donorRanks) do if v == ply:GetUserGroup() then isdonor = "This player is a donor."; symbolAdjust = symbolAdjust + 21; break end end
                for _, v in pairs(rhud_sb.managementRanks) do if v == ply:GetUserGroup() then ismanager = "This player is a manager."; symbolAdjust = symbolAdjust + 19; break end end
                local status = ply:GetFriendStatus()
                if status == "friend" and doneloading then isfriend = "This player is your friend."; symbolAdjust = symbolAdjust + 19 end
                if status == "blocked" and doneloading then isblocked = "You have blocked this player."; symbolAdjust = symbolAdjust + 19 end

				if not doneloading then symbolAdjust = 21 end

                if doneloading then
                    if ply:IsBot() then id = "bot" .. ply:UniqueID() end
                    //plykarma = shortenKarma(karma[id]["plus"] - karma[id]["minus"])
                end

                local plypanel = vgui.Create("DButton", teampanel)
                plypanel:SetSize(teampanel:GetWide() - 5, 36)
                plypanel:SetPos(0, 39 * (k - 1) + 25)
                plypanel:SetMouseInputEnabled(true)
                plypanel:SetText("")
                plypanel:SetTooltip("Click for more.")
                plypanel.DoClick = function()
                    local temp = {}
                    surface.SetFont("HUDNameDisplay")
                    for k, v in pairs(rhud_sb.subMenu) do
                        local tw, th = surface.GetTextSize(v)
                        table.insert(temp, 1, tw)
                    end
                    surface.SetFont("HUDNameDisplay")
                    local namw, namh = surface.GetTextSize(ply:Nick())
                    local wid = math.max(unpack(temp), namw) + 36
                    local hei = #temp * 25 + 23
                    local mousex, mousey = gui.MousePos()
                    local detailpanel = vgui.Create("DPanel", frame)
                    local shouldcheck = false
                    timer.Simple(0.1, function()
                        shouldcheck = true
                    end)
                    detailpanel:SetPos(mousex - 5, mousey - 5)
                    detailpanel:SetSize(wid, hei)
                    detailpanel:MakePopup()
                    detailpanel:SetKeyBoardInputEnabled(false)
                    detailpanel.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, cl[6])
                        draw.RoundedBox(4, 2, 10, w - 4, h - 12, Color(30, 30, 30))
                        draw.RoundedBox(4, 2, 0, w - 4, 18, cl[6])
                        draw.RoundedBox(0, 2, 10, w - 4, 8, cl[6])
                        draw.SimpleText(ply:Nick(), "HUDNameDisplay", w / 2, 2, cl[5], 1)
                    end
                    local panelx, panely = detailpanel:LocalToScreen(detailpanel:GetPos())

                    for k, v in pairs(rhud_sb.subMenu) do
                        local detailbutton = vgui.Create("DButton", detailpanel)
                        if ply:IsMuted() then detailbutton.drawtext = "Unmute" else detailbutton.drawtext = "Mute" end
                        detailbutton:SetSize(detailpanel:GetWide() - 8, 22)
                        detailbutton:SetPos(4, (k - 1) * 25 + 21)
                        detailbutton:SetText("")
                        detailbutton:SetKeyBoardInputEnabled(false)
                        detailbutton.Paint = function(self, w, h)
                            draw.RoundedBox(4, 0, 0, w, h, cl[1])
                            local drawtext = v
                            if string.lower(v) == "unmute" then drawtext = detailbutton.drawtext end
                            draw.SimpleText(drawtext, "HUDNameDisplay", w / 2, h / 2, Color(20, 20, 20), 1, 1)
                            mousex, mousey = gui.MousePos()
                            local shouldRemove = false
                            if mousex < panelx or mousex > panelx + detailpanel:GetWide() or mousey < panely or mousey > panely + detailpanel:GetTall() then
                                detailpanel:Remove()
                            end
                        end
                        if string.lower(v) == "unmute" then
                            detailbutton.DoClick = function()
                                if ply:IsMuted() then
                                    ply:SetMuted(false)
                                    detailbutton.drawtext = "Mute"
                                else
                                    ply:SetMuted(true)
                                    detailbutton.drawtext = "Unmute"
                                end
                            end
                        elseif string.lower(v) == "copy id" then
                            detailbutton.DoClick = function()
                                SetClipboardText(ply:SteamID())
                                chat.AddText(team.GetColor(ply:Team()), ply:Nick(), Color(255, 255, 255), "\'s ID has been copied to your clipboard.")
                            end
                        elseif string.lower(v) == "open profile" then
                            detailbutton.DoClick = function()
                                if !ply:IsBot() then
                                    gui.OpenURL("http://steamcommunity.com/profiles/" .. ply:SteamID64())
                                    frame:Remove()
                                end
                            end
                        end
                    end
                end
                plypanel.Paint = function(self, w, h)
                    if IsValid(ply) then
                        local bgColor = Color(40, 40, 40, 255)
                        if isdonor != false then bgColor = cl[2] end
                        if isadmin != false then bgColor = cl[3] end
                        if ismanager != false then bgColor = cl[4] end
                        if !ply:Alive() then bgColor = Color(60, 30, 30, 255) end

                        if plypanel:IsHovered() then
                            local hue, sat, val = ColorToHSV(bgColor)
                            bgColor = HSVToColor(hue, sat, val + 0.05)
                            //bgColor = Color(255, 0, 0)
                        end

                        draw.RoundedBox(4, 0, 0, w, h, bgColor)

                        //local tw, th
                        local timestring = timeToStr(ply:GetUTimeTotalTime())
                        local ping = ply:Ping()
                        local pingColor = Color(60, 255, 60)
                        local frags = ply:Frags()
                        //if frags < 0 then frags = 0 end
                        local kd = frags .. " / " .. ply:Deaths()

                        if starttime != os.time() then ping = ply:Ping() end
                        if ping > 250 then pingColor = Color(255, 60, 60) elseif ping > 100 then pingColor = Color(200, 220, 0) end
                        if ply:IsBot() then ping = "BOT"; pingColor = Color(255, 255, 255); kd = "BOT"; timestring = "BOT"; end

                        draw.SimpleText(ping, "HUDNumberDisplay", w - 35, 10, pingColor, 1, 0)
                        draw.SimpleText(timestring, "HUDNumberDisplay", w - 167, 10, Color(255, 255, 255), 1, 0)
                        draw.SimpleText(kd, "HUDNumberDisplay", w - 328, 10, Color(255, 255, 255), 1, 0)
                        draw.SimpleText(nick, "HUDLargerNumberDisplay", 6 + symbolAdjust + 34, 8, Color(255, 255, 255))

                        /*if doneloading then
                            plykarma = shortenKarma(karma[id]["plus"] - karma[id]["minus"])
                            karmawidth, _ = draw.SimpleText(plykarma, "HUDNumberDisplay", w - 28, 10, Color(255, 255, 255, 0), 2, 0)
                            //
                        end
                        //if plykarma != nil then draw.SimpleText(plykarma, "HUDNumberDisplay", w - 28 + karmadj, 10, Color(255, 255, 255), 2, 0) end
                        if cooldowninfo != nil then
                            if cooldowninfo["time"] < os.time() then
                                table.RemoveByValue(karma[LocalPlayer():SteamID64()]["cooldown"], cooldowninfo)
                                cooldowninfo = nil
                            end
                        end*/

                        /*for k, v in pairs(karma[LocalPlayer():SteamID64()]["cooldown"]) do
                            if v["id"] == id then
                                cooldowninfo = v
                                break
                            end
                        end*/

                    end
                end

                /*local placementpanel = vgui.Create("DPanel", plypanel)
                placementpanel:SetSize(plypanel:GetWide() - config.maxnamewidth - 36 - 19 - 19 - 15, plypanel:GetTall())
                placementpanel:SetPos(plypanel:GetWide() - placementpanel:GetWide(), 0)
                placementpanel.Paint = function(self, w, h) end

                if ply != LocalPlayer() then
                    local currentMuteMat
                    if ply:IsMuted() then currentMuteMat = mutedMaterial else currentMuteMat = unmutedMaterial end
                    local mutebutton = vgui.Create("DButton", plypanel)
                    mutebutton:SetSize(16, 16)
                    mutebutton:SetPos(36 + nickwidth + symbolAdjust + 10, plypanel:GetTall() / 2 - mutebutton:GetTall() / 2)
                    mutebutton:SetText("")
                    if ply:IsMuted() then mutebutton:SetTooltip("Unmute " .. ply:Nick()) else mutebutton:SetTooltip("Mute " .. ply:Nick()) end
                    mutebutton.Paint = function(self, w, h)
                        surface.SetDrawColor(Color(255, 255, 255))
                        surface.SetMaterial(currentMuteMat)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                    mutebutton.DoClick = function()
                        if ply:IsMuted() then
                            ply:SetMuted(false)
                            currentMuteMat = unmutedMaterial
                            mutebutton:SetTooltip("Unmute " .. ply:Nick())
                        else
                            ply:SetMuted(true)
                            currentMuteMat = mutedMaterial
                            mutebutton:SetTooltip("Mute " .. ply:Nick())
                        end
                    end
                end*/

                local avatar = vgui.Create("AvatarImage", plypanel)
                avatar:SetSize(32, 32)
                avatar:SetPos(2, 2)
                avatar:SetPlayer(ply)

                if !ply:IsBot() then
                    local avatarbutton = vgui.Create("DButton", avatar)
                    avatarbutton:SetSize(32, 32)
                    avatarbutton:SetPos(0, 0)
                    avatarbutton:SetText("")
                    avatarbutton:SetTooltip("Visit " .. ply:Nick() .. "'s profile!")
                    avatarbutton.Paint = function() end
                    avatarbutton.DoClick = function()
                        frame:Remove()
                        gui.OpenURL("http://steamcommunity.com/profiles/" .. ply:SteamID64())
                    end
                end

                local texturedMaterial
                local tooltip
                if isadmin then texturedMaterial = adminMaterial; tooltip = isadmin end
                if isdonor then texturedMaterial = donorMaterial; tooltip = isdonor end
                if ismanager then texturedMaterial = managementMaterial; tooltip = ismanager end
                if (isadmin or ismanager) and doneloading == true then
                    local iconpanel1 = vgui.Create("DPanel", plypanel)
                    iconpanel1:SetSize(16, 16)
                    iconpanel1:SetPos(6 + 34, 10)
                    iconpanel1:SetTooltip(tooltip)
                    iconpanel1.Paint = function(self, w, h)
                        surface.SetDrawColor(Color(255, 255, 255))
                        surface.SetMaterial(texturedMaterial)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                elseif isdonor and doneloading == true then
                    local iconpanel1 = vgui.Create("DButton", plypanel)
                    iconpanel1:SetSize(16, 16)
                    iconpanel1:SetPos(6 + 34, 10)
                    iconpanel1:SetText("")
                    iconpanel1:SetTooltip(tooltip)
                    iconpanel1.Paint = function(self, w, h)
                        surface.SetDrawColor(Color(255, 255, 255))
                        surface.SetMaterial(texturedMaterial)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                    iconpanel1.DoClick = function()
                        frame:Remove()
                        gui.OpenURL("https://hgaming.net/donate.html")
                    end
                end

                local texturedMaterial2
                if isfriend then texturedMaterial2 = friendMaterial; tooltip = isfriend end
                if isblocked then texturedMaterial2 = blockedMaterial; tooltip = isblocked end
                if (isfriend or isblocked) and doneloading == true then
                    local iconpanel2 = vgui.Create("DPanel", plypanel)
                    local adj = 0
                    if isadmin or isdonor or ismanager then adj = 18 end
                    if ismanager then adj = 18 end
                    if isdonor then adj = 20 end
                    iconpanel2:SetSize(16, 16)
                    iconpanel2:SetPos(6 + adj + 34, 10)
                    iconpanel2:SetTooltip(tooltip)
                    iconpanel2.Paint = function(self, w, h)
                        surface.SetDrawColor(Color(255, 255, 255))
                        surface.SetMaterial(texturedMaterial2)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                end

                if ply.rafk_bool != nil and ply.rafk_duration != nil then
                    local iconpanel3 = vgui.Create("DPanel", plypanel)
                    iconpanel3:SetSize(16, 16)
                    iconpanel3:SetPos(nickwidth + symbolAdjust + 44, 10)
                    iconpanel3.Paint = function(s, w, h)
                        if ply.rafk_bool then
                            local duration = CurTime() - ply.rafk_duration
                            s:SetTooltip(ply:Nick() .. " has been AFK for " .. math.floor(duration / 60) .. " minutes, " .. math.Round(duration % 60) .. " seconds.")
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(afkMaterial)
                            surface.DrawTexturedRect(0, 0, 16, 16)
                        end
                    end
                end

                if doneloading == true then
                    /*local karmacolors = {Color(255, 60, 60), Color(60, 255, 60)}

                    local karmaup = vgui.Create("DButton", plypanel)
                    karmaup:SetSize(16, 16)
                    karmaup:SetPos(plypanel:GetWide() - 60, 10)
                    karmaup:SetText("")
                    karmaup.Paint = function(self, w, h)
                        karmawidth, _ = draw.SimpleText(plykarma, "HUDNumberDisplay", w - 28, 10, Color(255, 255, 255, 0), 2, 0)
                        karmaup:SetPos(plypanel:GetWide() - 49 - karmawidth, 10)
                        surface.SetDrawColor(Color(255, 255, 255))
                        if cooldowninfo != nil then if cooldowninfo["positive"] == true then surface.SetDrawColor(karmacolors[2]) end end
                        surface.SetMaterial(upMaterial)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                    karmaup.DoClick = function()
                        if id != LocalPlayer():SteamID64() then
                            local info = {}
                            info.positive = true
                            info.id = id

                            net.Start("rhud_rate")
                            net.WriteTable(info)
                            net.SendToServer()
                        else
                            chat.AddText(cl[1], "WOAH!", Color(255, 255, 255), " You can't rate yourself!")
                        end
                    end

                    local karmapanel = vgui.Create("DPanel", plypanel)
                    karmapanel:SetTooltip("")
                    karmapanel.Paint = function(self, w, h)
                        if plykarma != nil and karmadj != nil then
                            karmapanel:SetTooltip(karma[id]["plus"] - karma[id]["minus"])
                            karmapanel:SizeToContents()
                            karmapanel:SetPos(plypanel:GetWide() - 22 - karmawidth + karmadj - 5, 10)
                        end
                    end

                    local karmalabel = vgui.Create("DLabel", karmapanel)
                    karmalabel:SetText("")
                    karmalabel:SetPos(0, 0)
                    karmalabel:SetFont("HUDNumberDisplay")
                    karmalabel.Paint = function(self, w, h)
                        if plykarma != nil then
                            karmalabel:SetText(plykarma)
                            karmalabel:SizeToContents()
                            karmapanel:SizeToChildren(true, true)
                        end
                    end

                    local karmadown = vgui.Create("DButton", plypanel)
                    karmadown:SetSize(16, 16)
                    karmadown:SetPos(plypanel:GetWide() - 22, 10)
                    karmadown:SetText("")
                    karmadown.Paint = function(self, w, h)
                        surface.SetDrawColor(Color(255, 255, 255))
                        if cooldowninfo != nil then if cooldowninfo["positive"] == false then surface.SetDrawColor(karmacolors[1]) end end
                        surface.SetMaterial(downMaterial)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                        if karmadj != nil then
                            karmadown:SetPos(plypanel:GetWide() - 22 + karmadj, 10)
                            karmaup:SetPos(plypanel:GetWide() - 49 - karmawidth + karmadj, 10)
                        end
                    end
                    karmadown.DoClick = function()
                        if id != LocalPlayer():SteamID64() then
                            local info = {}
                            info.positive = false
                            info.id = id

                            net.Start("rhud_rate")
                            net.WriteTable(info)
                            net.SendToServer()
                        else
                            chat.AddText(cl[1], "WOAH!", Color(255, 255, 255), " You can't rate yourself!")
                        end
                    end*/
                else
                    local loadingicon = vgui.Create("DPanel", plypanel)
                    loadingicon:SetSize(16, 16)
                    loadingicon:SetPos(6 + 34, 10)
                    loadingicon:SetTooltip("This player is still loading.")
                    loadingicon.Paint = function(self, w, h)
                        surface.SetDrawColor(Color(255, 255, 255))
                        surface.SetMaterial(loadingMaterial)
                        surface.DrawTexturedRect(0, 0, 16, 16)
                    end
                end
            end
        end
    end

    function rhud_sb:hide()
        frame:Remove()
    end
end

/*net.Receive("rhud_rate", function(len)
    local info = net.ReadTable()
    local cl = Color(48, 179, 255)
    local wt = Color(255, 255, 255)
    if info.success == false then

        local plyid = info.id
        local targ
        if string.find(plyid, "bot") then targ = player.GetByUniqueID(string.sub(plyid, 4)) else targ = player.GetBySteamID64(plyid) end

        local timeleft = info.cooldown
        local minutes = math.floor(timeleft / 60)
        local hours = math.floor(minutes / 60)
        minutes = minutes - (hours * 60)
        local seconds = timeleft - (hours * 3600) - (minutes * 60)
        chat.AddText(wt, "You will be able to rate ", team.GetColor(targ:Team()), targ:Nick(), wt, " again in ", cl, tostring(hours), wt, " hours, ", cl, tostring(minutes), wt, " minutes and ", cl, tostring(seconds), wt, " seconds.")

    elseif info.success == true then
        local plyid = info.id
        local callerid = info.callerid
        local id = LocalPlayer():SteamID64()
        if LocalPlayer():IsBot() then id = "bot" .. LocalPlayer():UniqueID() end

        local plytarg
        if string.find(plyid, "bot") then plytarg = player.GetByUniqueID(string.sub(plyid, 4)) else plytarg = player.GetBySteamID64(plyid) end
        local callertarg
        if string.find(callerid, "bot") then callertarg = player.GetByUniqueID(string.sub(callerid, 4)) else callertarg = player.GetBySteamID64(callerid) end

        if callerid == id then
            for k, v in pairs(karma[id]["cooldown"]) do
                if v["id"] == info.id then
                    table.remove(karma[id]["cooldown"], k)
                end
            end
            table.insert(karma[id]["cooldown"], 1, info.cooldown)

            local posorneg = {Color(255, 60, 60), "negative"}
            if info.positive == true then posorneg = {Color(60, 255, 60), "positive"} end
            chat.AddText(wt, "You have given ", team.GetColor(plytarg:Team()), plytarg:Nick(), wt, " a ", posorneg[1], posorneg[2], wt, " rating.")
        end

        if plyid == id then
            local posorneg = {Color(255, 60, 60), "negative"}
            if info.positive == true then posorneg = {Color(60, 255, 60), "positive"} end
            chat.AddText(wt, "You have recieved a ", posorneg[1], posorneg[2], wt, " rating from ", team.GetColor(callertarg:Team()), callertarg:Nick(), wt, ".")
        end

        if info.positive == true then
            karma[plyid]["plus"] = karma[plyid]["plus"] + 1
        else
            karma[plyid]["minus"] = karma[plyid]["minus"] + 1
        end
    else
        print("netmessage error")
    end
end)*/

hook.Add("InitPostEntity", "rhud_initscoreboard", function()
    timer.Simple(10, function()
        init = true
    end)

    function GAMEMODE:ScoreboardShow()
        if init == true then
            rhud_sb:show()
        end
    end

    function GAMEMODE:ScoreboardHide()
        if init == true then
            rhud_sb:hide()
        end
    end
end)
