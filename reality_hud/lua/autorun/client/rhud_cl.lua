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

include("hud/main.lua")
include("hud/float.lua")
--include("hud/float2.lua")
include("hud/killfeed.lua")
include("hud/scoreboard.lua")
-- include("hud/switcher.lua")

hook.Add("InitPostEntity", "sendInitMessage", function()
	local color = Color(48, 179, 255)
	net.Start("rhud_ks-init")
	net.SendToServer()
	-- chat.AddText(color, "[", Color(255, 255, 255), "R-HUD", color, "]", Color(255, 255, 255), " Initialized. Welcome, ", color, LocalPlayer():Name(), Color(255, 255, 255), ".")
end)

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudPoisonDamageIndicator = true,
	CHudSquadStatus = true,
	CHudGeiger = true,
	CHudWeapon = true,
	CHudSecondaryAmmo = true,
	CHudVoiceStatus = true,
	CHudVoiceSelfStatus = true,
}

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	if(hide[name]) then return false end
end)

net.Receive("rhud_nodrive", function(len)
	local color = Color(48, 179, 255)
	chat.AddText(color, "[", Color(255, 255, 255), "R-UTIL", color, "]", Color(255, 255, 255), " The driving of props is disabled.")
end)
