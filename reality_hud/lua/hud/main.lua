local specialWeapons = {
	{"weapon_rpg", "RPG_Round"},
	{"weapon_frag", "Grenade"},
	{"weapon_slam", "slam"},
    {"m9k_damascus", ""},
    {"m9k_fists", ""},
    {"m9k_knife", ""},
    {"m9k_machete", ""},
    {"pist_weagon", ""}
}

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

surface.CreateFont( "HUDLargeNumberDisplay", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 2000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDLargerNumberDisplay", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 20,
	weight = 2000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDNumberDisplay", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 18,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDSmallNumberDisplay", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 15,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDNameDisplay", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 15,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDSuperSmall", {
	font = "Roboto Light", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 12,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "HUDScoreboard", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 12,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )


local smoothHealth = 100
local smoothArmor = 255
local opacityArmor = 0
rhud_ks = rhud_ks or {}

net.Receive("rhud_ks-exclaim", function(len)
	local info = net.ReadTable()
	local ply = info.ply
	local killer = info.killer
	local death = info.death
	local kills = info.kills
	local msg = info.msg
	local cl = Color(48, 179, 255)
	local wt = Color(255, 255, 255)

	if death == true then
		chat.AddText(wt, string.upper(msg), "! ", team.GetColor(killer:Team()), killer:Nick(), wt, " ended ", team.GetColor(ply:Team()), ply:Nick(), wt, "\'s kill streak of ", cl, tostring(kills), wt, "!")
	elseif death == false then
		chat.AddText(wt, string.upper(msg), "! ", team.GetColor(ply:Team()), ply:Nick(), wt, " is on a ", cl, tostring(kills), wt, " kill streak!")
	else
		chat.AddText(wt, string.upper(msg), "! ", team.GetColor(ply:Team()), ply:Nick(), wt, "\'s kill streak of ", cl, tostring(kills), wt, " was lost!")
	end
end)

net.Receive("rhud_ks-init", function(len)
	rhud_ks = net.ReadTable()
end)

net.Receive("rhud_ks-new", function(len)
	local ply = net.ReadEntity()
	rhud_ks[ply:SteamID64()] = 0
end)

net.Receive("rhud_ks-dc", function(len)
	local s64 = net.ReadString()
	rhud_ks[s64] = nil
end)

net.Receive("rhud_ks-add", function(len)
	local info = net.ReadTable()
	local killer = info.killer
	local death = info.death
	local id
	
	if (killer == nil or !IsValid(killer)) and (death == nil or !IsValid(death)) then return end

	if killer != nil and killer.SteamID64 and killer:SteamID64() != nil then
		id = killer:SteamID64()
		if rhud_ks[id] == nil then rhud_ks[id] = 0 end
		rhud_ks[id] = rhud_ks[id] + 1
	end

	id2 = death:SteamID64()
	if death:IsBot() then id2 = "bot" .. death:UniqueID() end
	rhud_ks[id2] = 0
end)
-- 
net.Receive("rhud_ks-reset", function(len)
	rhud_ks = net.ReadTable()
end)

local healthPath = Material("r_hud/heart.png")
local armorPath = Material("r_hud/armor.png")
local weaponPath = Material("r_hud/gun_icon.png")
local timePath = Material("r_hud/time.png")
local skullPath = Material("r_hud/skull.png")

function drawHud()
	local lp = LocalPlayer()

	-- Health
	if lp:GetNWBool("rbuild_enabled", false) == false then
		smoothHealth = Lerp(10 * FrameTime(), smoothHealth, lp:Health())
		local healthTextHeight, healthTextWidth = draw.SimpleText(lp:Health() .. "%", "HUDNumberDisplay", 5, 5, Color(255, 255, 255, 0), 0, 0)
		local clampedHealth = math.Clamp(smoothHealth * 2, healthTextWidth + 38, 200)

		draw.RoundedBox(8, 10, ScrH() - 45, 236, 35, Color(20, 20, 20))
		if lp:Health() > 0 and lp:Alive() then
			draw.RoundedBox(8, 10, ScrH() - 45, clampedHealth, 35, Color(255, 80, 80))
			draw.RoundedBox(0, clampedHealth + 4, ScrH() - 45, 8, 35, Color(255, 80, 80))
			draw.SimpleText(lp:Health() .. "%", "HUDNumberDisplay", clampedHealth - 17, ScrH() - 36, Color(20, 20, 20), 1, 0)
		end

		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(healthPath)
		surface.DrawTexturedRect(220, ScrH() - 36, 16, 16)

		-- Armor
		if lp:Armor() > 0 and lp:Alive() then
			opacityArmor = Lerp(10 * FrameTime(), opacityArmor, 255)
		else
			opacityArmor = Lerp(10 * FrameTime(), opacityArmor, 0)
		end
		smoothArmor = Lerp(10 * FrameTime(), smoothArmor, lp:Armor())
		if lp:Armor() > 0 then
			local armorTextHeight, armorTextWidth = draw.SimpleText(lp:Armor() .. "%", "HUDNumberDisplay", 0, 0, Color(255, 255, 255, 0), 0, 0)
			local clampedArmor = math.Clamp(smoothArmor * 2, armorTextWidth + 38, 200)
			draw.RoundedBox(8, 10, ScrH() - 85, 236, 35, Color(20, 20, 20, opacityArmor))
			draw.RoundedBox(8, 10, ScrH() - 85, clampedArmor, 35, Color(80, 80, 255, opacityArmor))
			draw.RoundedBox(0, clampedArmor + 4, ScrH() - 85, 8, 35, Color(80, 80, 255, opacityArmor))
			draw.SimpleText(lp:Armor() .. "%", "HUDNumberDisplay", clampedArmor - 17, ScrH() - 76, Color(20, 20, 20, opacityArmor), 1, 0)

			surface.SetDrawColor(Color(255, 255, 255))
			surface.SetMaterial(armorPath)
			surface.DrawTexturedRect(220, ScrH() - 76, 16, 16)
		end
	end

	-- Weapon
	if lp:Health() > 0 and IsValid(lp) and lp:Alive() and lp != nil and lp:GetActiveWeapon() != nil and IsValid(lp:GetActiveWeapon()) then
		local cur_wep = lp:GetActiveWeapon()
		local cur_wep_name = lp:GetActiveWeapon():GetClass()

		local max_clip1 = cur_wep:GetMaxClip1()
		local cur_clip1 = cur_wep:Clip1()
		local reserve_clip1 = lp:GetAmmoCount(cur_wep:GetPrimaryAmmoType())

		local reserve_clip2 = lp:GetAmmoCount(cur_wep:GetSecondaryAmmoType())

		local wepNameWidth, wepNameHeight = draw.SimpleText(string.upper(cur_wep:GetPrintName()), "HUDNumberDisplay", 0, 0, Color(20, 20, 20, 0), 0, 0)

		draw.RoundedBox(8, ScrW() - wepNameWidth - 66, ScrH() - 45, wepNameWidth + 36, 35, Color(20, 20, 20))
		draw.RoundedBox(8, ScrW() - wepNameWidth - 30, ScrH() - 45, wepNameWidth + 20, 35, Color(255, 255, 255))
		draw.RoundedBox(0, ScrW() - wepNameWidth - 32, ScrH() - 45, 8, 35, Color(255, 255, 255))
		draw.SimpleText(string.upper(cur_wep:GetPrintName()), "HUDNumberDisplay", ScrW() - 20, ScrH() - 36, Color(20, 20, 20), 2, 0)

		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(weaponPath)
		surface.DrawTexturedRect(ScrW() - wepNameWidth - 57, ScrH() - 36, 16, 16)

		local special = false
		for k, v in pairs(specialWeapons) do
			if v[1] == cur_wep:GetClass() then
				special = v
			end
		end

		if (special == false) then
			if max_clip1 > 0 then
				local primaryAmmoWidth, primaryAmmoHeight = draw.SimpleText(cur_clip1 .. "/" .. max_clip1 .. "    " .. reserve_clip1, "HUDNumberDisplay", 0, 0, Color(20, 20, 20, 0), 2, 0)

				draw.RoundedBox(8, ScrW() - primaryAmmoWidth - 44, ScrH() - 85, primaryAmmoWidth + 10, 35, Color(20, 20, 20))
				draw.RoundedBox(8, ScrW() - primaryAmmoWidth - 30, ScrH() - 85, primaryAmmoWidth + 20, 35, Color(255, 255, 255))
				draw.RoundedBox(0, ScrW() - primaryAmmoWidth - 32, ScrH() - 85, 8, 35, Color(255, 255, 255))
				draw.SimpleText(cur_clip1 .. "/" .. max_clip1 .. "    " .. reserve_clip1, "HUDNumberDisplay", ScrW() - 22, ScrH() - 76, Color(20, 20, 20), 2, 0)
			end

			if cur_wep:GetSecondaryAmmoType() > -1 then
				local secAmmoWidth, secAmmoheight = draw.SimpleText(reserve_clip2, "HUDNumberDisplay", ScrW() - 20, ScrH() - 116, Color(20, 20, 20, 0), 2, 0)

				draw.RoundedBox(8, ScrW() - secAmmoWidth - 44, ScrH() - 125, secAmmoWidth + 10, 35, Color(20, 20, 20))
				draw.RoundedBox(8, ScrW() - secAmmoWidth - 30, ScrH() - 125, secAmmoWidth + 20, 35, Color(255, 255, 255))
				draw.RoundedBox(0, ScrW() - secAmmoWidth - 32, ScrH() - 125, 8, 35, Color(255, 255, 255))
				draw.SimpleText(reserve_clip2, "HUDNumberDisplay", ScrW() - 22, ScrH() - 116, Color(20, 20, 20), 2, 0)
			end
		else
            if special[2] != "" then
                local ammotype = lp:GetAmmoCount(special[2])
                local tertAmmoWidth, tertAmmoHeight = draw.SimpleText(ammotype, "HUDNumberDisplay", 0, 0, Color(20, 20, 20, 0), 2, 0)

                draw.RoundedBox(8, ScrW() - tertAmmoWidth - 44, ScrH() - 85, tertAmmoWidth + 10, 35, Color(20, 20, 20))
                draw.RoundedBox(8, ScrW() - tertAmmoWidth - 30, ScrH() - 85, tertAmmoWidth + 20, 35, Color(255, 255, 255))
                draw.RoundedBox(0, ScrW() - tertAmmoWidth - 32, ScrH() - 85, 8, 35, Color(255, 255, 255))
                draw.SimpleText(ammotype, "HUDNumberDisplay", ScrW() - 22, ScrH() - 76, Color(20, 20, 20), 2, 0)
            end
		end
	end

	-- Crosshair
	if lp:Health() > 0 and IsValid(lp) and lp:Alive() and lp != nil then
		local tr = lp:GetEyeTrace().Entity
		if IsValid(tr) and tr != nil then
			if tr:GetClass() != "worldspawn" then
				draw.RoundedBox(0, ScrW() / 2 - 3, ScrH() / 2 - 3, 6, 6, Color(66, 134, 244))
			end
			if tr:GetClass() == "player" then
				draw.RoundedBox(0, ScrW() / 2 - 3, ScrH() / 2 - 3, 6, 6, Color(244, 152, 65))
			end
		end
		draw.RoundedBox(0, ScrW() / 2 - 2, ScrH() / 2 - 2, 4, 4, Color(20, 20, 20))
		draw.RoundedBox(0, ScrW() / 2 - 1, ScrH() / 2 - 1, 2, 2, Color(255, 255, 255))
	end

	-- Playtime
	local tw, th = draw.SimpleText(timeToStr(LocalPlayer():GetUTimeTotalTime()), "HUDNumberDisplay", ScrW() - 19, 18, Color(20, 20, 20, 0), 2, 0)
	local tw2, th2 = draw.SimpleText(timeToStr(LocalPlayer():GetUTimeSessionTime()), "HUDNumberDisplay", 0, 0, Color(0, 0, 0, 0), 2, 0)

	local atw = math.max(tw, tw2)

	draw.RoundedBox(8, ScrW() - atw - 36 - 31, 10, atw + 36 + 20, 50, Color(20, 20, 20))
	draw.RoundedBox(8, ScrW() - atw - 30, 10, atw + 20, 50, Color(255, 255, 255))
	draw.RoundedBox(0, ScrW() - atw - 30, 10, 20, 50, Color(255, 255, 255))

	surface.SetDrawColor(Color(255, 255, 255))
	surface.SetMaterial(timePath)
	surface.DrawTexturedRect(ScrW() - atw - 56, 26, 16, 16)

	draw.SimpleText(timeToStr(LocalPlayer():GetUTimeTotalTime()), "HUDNumberDisplay", ScrW() - 20, 16, Color(20, 20, 20), 2, 0)
	local session = timeToStr(LocalPlayer():GetUTimeSessionTime())
	if session == nil then session = "<1m" end
	draw.SimpleText(session, "HUDNumberDisplay", ScrW() - 20, 37, Color(20, 20, 20), 2, 0)

	-- Killstreak
	if LocalPlayer():SteamID64() != nil then
		local tw, th = draw.SimpleText(rhud_ks[LocalPlayer():SteamID64()], "HUDNumberDisplay", 0, 0, Color( 0, 0, 0, 0), 0, 0)
		draw.RoundedBox(8, ScrW() - tw - 20 - 36 - 10, 65, tw + 36 + 20, 35, Color(20, 20, 20))
		draw.RoundedBox(8, ScrW() - tw - 20 - 10, 65, tw + 20, 35, Color(255, 255, 255))
		draw.RoundedBox(0, ScrW() - tw - 20 - 10 - 1, 65, 10, 35, Color(255, 255, 255))
		draw.SimpleText(rhud_ks[LocalPlayer():SteamID64()], "HUDNumberDisplay", ScrW() - 21, 74, Color(20, 20, 20), 2, 0)

		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(skullPath)
		surface.DrawTexturedRect(ScrW() - tw - 56, 75, 16, 16)
	end
end

hook.Add("HUDPaint", "drawHud", drawHud)
