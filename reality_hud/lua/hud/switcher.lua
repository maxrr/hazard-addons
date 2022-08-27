--[[ Config ]]--

local MAX_SLOTS = 6
local CACHE_TIME = 1
local MOVE_SOUND = "Player.WeaponSelectionMoveSlot"
local SELECT_SOUND = "Player.WeaponSelected"

--[[ Instance variables ]]--

local iCurSlot = 0 -- Currently selected slot. 0 = no selection
local iCurPos = 1 -- Current position in that slot
local flNextPrecache = 0 -- Time until next precache
local flSelectTime = 0 -- Time the weapon selection changed slot/visibility states. Can be used to close the weapon selector after a certain amount of idle time
local iWeaponCount = 0 -- Total number of weapons on the player

-- Weapon cache; table of tables. tCache[Slot + 1] contains a table containing that slot's weapons. Table's length is tCacheLength[Slot + 1]
local tCache = tCache or {}

-- Weapon cache length. tCacheLength[Slot + 1] will contain the number of weapons that slot has
local tCacheLength = tCacheLength or {}

--[[ Weapon switcher ]]--

local r_padding = 4
local r_width = (ScrW() / 2.4) / 4
local r_height = 29

local r_offsetx = (ScrW() / 2) - (((r_width + r_padding) * 6) / 2)
local r_offsety = ScrH() / 20

local r_wepheight = 23

local r_physattack = false

hook.Add("DrawPhysgunBeam", "r_physattack", function(ply, wep, enabled, target, bone, deltaPos)
    r_physattack = enabled
end)

local function r_init()
    r_width = (ScrW() / 2.4) / 4
    r_offsetx = (ScrW() / 2) - (((r_width + r_padding) * 6) / 2)
    r_offsety = ScrH() / 20
end

timer.Create("rhud_updateresolution", 10, 0, r_init)

local r_opac = 0
local r_opac_should = 255

local function r_startTimeout()
    if !timer.Exists("r_timeout") then
        timer.Create("r_timeout", 3, 1, function()
            r_opac_should = 0
            timer.Simple(0.5, function()
                iCurSlot = 0
                iCurPos = 1
            end)
        end)
    else
        timer.Remove("r_timeout")
        r_startTimeout()
    end
end

local function checkNameLength(str)
    local tw, th = draw.SimpleText(str, "HUDSmallNumberDisplay", 0, 0, Color(255, 255, 255, 0), 1, 1)
    if tw + 15 > r_width then
        local sub = string.sub(str, 0, string.len(str) - 5)
        sub = sub .. "..."
        return checkNameLength(sub)
    else
        return str
    end
end

local function DrawWeaponHUD()
    r_opac = Lerp(FrameTime() * 15, r_opac, r_opac_should)
    for k, v in pairs(tCache[iCurSlot]) do
        local name = string.upper(v:GetPrintName())
        if name == "#GMOD_CAMERA" then name = "CAMERA" end
        local drawcol = Color(30, 30, 30, r_opac)
        -- if k == iCurPos then drawcol = Color(60, 60, 60, r_opac) end

        local x = r_offsetx + (r_width * (iCurSlot - 1)) + (r_padding * (iCurSlot - 1))
        local r_wep_y = r_offsety + r_height + (k - 1) * (r_wepheight + 1) + 2

        draw.RoundedBox(4, x, r_wep_y, r_width, r_wepheight, drawcol)
        draw.SimpleText(checkNameLength(name), "HUDSmallNumberDisplay", x + r_width / 2, r_wep_y + r_wepheight / 2, Color(255, 255, 255, r_opac), 1, 1)
        if k == iCurPos then
            draw.RoundedBox(4, x, r_wep_y, 5, r_wepheight, Color(66, 134, 244, r_opac))
        end
    end
	for i = 1, MAX_SLOTS do
        local x = r_offsetx + (r_width * (i - 1)) + (r_padding * (i - 1))
        draw.RoundedBox(4, x, r_offsety, r_width, r_height, Color(255, 255, 255, r_opac))
        draw.SimpleText(i, "HUDNumberDisplay", r_width / 2 + x - 2, r_height / 2 + r_offsety, Color(20, 20, 20, r_opac), 2, 1)
        draw.SimpleText("[" .. tCacheLength[i] .. "]", "HUDSmallNumberDisplay", r_width / 2 + x, r_height / 2 + r_offsety, Color(20, 20, 20, r_opac), 0, 1)
    end
end

--[[ Implementation ]]--

-- Initialize tables with slot number
for i = 1, MAX_SLOTS do
	tCache[i] = {}
	tCacheLength[i] = 0
end

local pairs = pairs
local tonumber = tonumber
local RealTime = RealTime
local LocalPlayer = LocalPlayer
local string_lower = string.lower
local input_SelectWeapon = input.SelectWeapon

local function PrecacheWeps()
	-- Reset all table values
	for i = 1, MAX_SLOTS do
		for j = 1, tCacheLength[i] do
			tCache[i][j] = nil
		end

		tCacheLength[i] = 0
	end

	-- Update the cache time
	flNextPrecache = RealTime() + CACHE_TIME
	iWeaponCount = 0

	-- Discontinuous table
	for _, pWeapon in pairs(LocalPlayer():GetWeapons()) do
		iWeaponCount = iWeaponCount + 1

		-- Weapon slots start internally at "0"
		-- Here, we will start at "1" to match the slot binds
		local iSlot = pWeapon:GetSlot() + 1

		if (iSlot <= MAX_SLOTS) then
			-- Cache number of weapons in each slot
			local iLen = tCacheLength[iSlot] + 1
			tCacheLength[iSlot] = iLen
			tCache[iSlot][iLen] = pWeapon
		end
	end

	-- Make sure we're not pointing out of bounds
	if (iCurSlot ~= 0) then
		local iLen = tCacheLength[iCurSlot]

		if (iLen < iCurPos) then
			if (iLen == 0) then
				iCurSlot = 0
			else
				iCurPos = iLen
			end
		end
	end
end

local cl_drawhud = GetConVar("cl_drawhud")

hook.Add("HUDPaint", "GS_WeaponSelector", function()
	if (iCurSlot == 0 or not cl_drawhud:GetBool()) then
        r_opac = 0
		return
	end

	local pPlayer = LocalPlayer()

	-- Don't draw in vehicles unless weapons are allowed to be used
	-- Or while dead!
	if (pPlayer:IsValid() and pPlayer:Alive() and (not pPlayer:InVehicle() or pPlayer:GetAllowWeaponsInVehicle())) then
		if (flNextPrecache <= RealTime()) then
			PrecacheWeps()
		end

		DrawWeaponHUD()
	else
		iCurSlot = 0
	end
end)

hook.Add("PlayerBindPress", "GS_WeaponSelector", function(pPlayer, sBind, bPressed)
	if (not pPlayer:Alive() or pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle()) then
        r_opac = 0
		return
	end

	sBind = string_lower(sBind)

	-- Close the menu
	if (sBind == "cancelselect") then
		if (bPressed) then
			iCurSlot = 0
		end

		return true
	end

	-- Move to the weapon before the current
	if (sBind == "invprev") then
		if (not bPressed or r_physattack == true) then
			return true
		end

        r_opac_should = 255

		PrecacheWeps()
        r_startTimeout()

		if (iWeaponCount == 0) then
			return true
		end

		local bLoop = iCurSlot == 0

		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[1] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 2, tCacheLength[iSlot] do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i - 1
							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)
					return true
				end

				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == 1) then
			repeat
				if (iCurSlot <= 1) then
					iCurSlot = MAX_SLOTS
				else
					iCurSlot = iCurSlot - 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			iCurPos = tCacheLength[iCurSlot]
		else
			iCurPos = iCurPos - 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Move to the weapon after the current
	if (sBind == "invnext") then
		if (not bPressed or r_physattack == true) then
			return true
		end

        r_opac_should = 255
		PrecacheWeps()
        r_startTimeout()

		-- Block the action if there aren't any weapons available
		if (iWeaponCount == 0) then
			return true
		end

		-- Lua's goto can't jump between child scopes
		local bLoop = iCurSlot == 0

		-- Weapon selection isn't currently open, move based on the active weapon's position
		if (bLoop) then
			local pActiveWeapon = pPlayer:GetActiveWeapon()

			if (pActiveWeapon:IsValid()) then
				local iSlot = pActiveWeapon:GetSlot() + 1
				local iLen = tCacheLength[iSlot]
				local tSlotCache = tCache[iSlot]

				if (tSlotCache[iLen] ~= pActiveWeapon) then
					iCurSlot = iSlot
					iCurPos = 1

					for i = 1, iLen - 1 do
						if (tSlotCache[i] == pActiveWeapon) then
							iCurPos = i + 1

							break
						end
					end

					flSelectTime = RealTime()
					pPlayer:EmitSound(MOVE_SOUND)

					return true
				end

				-- At the end of a slot, move to the next one
				iCurSlot = iSlot
			end
		end

		if (bLoop or iCurPos == tCacheLength[iCurSlot]) then
			-- Loop through the slots until one has weapons
			repeat
				if (iCurSlot == MAX_SLOTS) then
					iCurSlot = 1
				else
					iCurSlot = iCurSlot + 1
				end
			until(tCacheLength[iCurSlot] ~= 0)

			-- Start at the beginning of the new slot
			iCurPos = 1
		else
			-- Bump up the position
			iCurPos = iCurPos + 1
		end

		flSelectTime = RealTime()
		pPlayer:EmitSound(MOVE_SOUND)

		return true
	end

	-- Keys 1-6
	if (sBind:sub(1, 4) == "slot") then
		local iSlot = tonumber(sBind:sub(5))

		-- If the command is slot#, use it for the weapon HUD
		-- Otherwise, let it pass through to prevent false positives
		if (iSlot == nil) then
            r_opac = 0
			return
		end

		if (not bPressed) then
			return true
		end

        r_opac_should = 255
		PrecacheWeps()
        r_startTimeout()

		-- Play a sound even if there aren't any weapons in that slot for "haptic" (really auditory) feedback
		if (iWeaponCount == 0) then
			pPlayer:EmitSound(MOVE_SOUND)
			return true
		end

		-- If the slot number is in the bounds
		if (iSlot <= MAX_SLOTS) then
			-- If the slot is already open
			if (iSlot == iCurSlot) then
				-- Start back at the beginning
				if (iCurPos == tCacheLength[iCurSlot]) then
					iCurPos = 1
				-- Move one up
				else
					iCurPos = iCurPos + 1
				end
			-- If there are weapons in this slot, display them
			elseif (tCacheLength[iSlot] ~= 0) then
				iCurSlot = iSlot
				iCurPos = 1
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(MOVE_SOUND)
		end

		return true
	end

	-- If the weapon selection is currently open
	if (iCurSlot ~= 0) then
		if (sBind == "+attack") then
			-- Hide the selection
			local pWeapon = tCache[iCurSlot][iCurPos]
			iCurSlot = 0

			-- If the weapon still exists and isn't the player's active weapon
			if (pWeapon:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
				input_SelectWeapon(pWeapon)
			end

			flSelectTime = RealTime()
			pPlayer:EmitSound(SELECT_SOUND)

			return true
		end

		-- Another shortcut for closing the selection
		if (sBind == "+attack2") then
			flSelectTime = RealTime()
			iCurSlot = 0

			return true
		end
	end
end)
