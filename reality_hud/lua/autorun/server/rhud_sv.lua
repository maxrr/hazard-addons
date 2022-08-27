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

AddCSLuaFile("autorun/client/rhud_cl.lua")
AddCSLuaFile("hud/float.lua")
//AddCSLuaFile("hud/float2.lua")
AddCSLuaFile("hud/main.lua")
// AddCSLuaFile("hud/switcher.lua")
AddCSLuaFile("hud/killfeed.lua")
AddCSLuaFile("hud/scoreboard.lua")

include("hud/killfeed_sv.lua")
//include("hud/scoreboard_sv.lua")

/*resource.AddFile("resource/fonts/Roboto-Light.ttf")
resource.AddFile("materials/r_hud/armor.png")
resource.AddFile("materials/r_hud/gun_icon.png")
resource.AddFile("materials/r_hud/heart.png")
resource.AddFile("materials/r_hud/time.png")
resource.AddFile("materials/r_hud/mic.png")
resource.AddFile("materials/r_hud/mic_muted.png")
resource.AddFile("materials/r_hud/chat.png")
resource.AddFile("materials/r_hud/star.png")
resource.AddFile("materials/r_hud/skull.png")
resource.AddFile("materials/r_hud/skull_big.png")*/

resource.AddWorkshop("1343339035")

util.AddNetworkString("rhud_nodrive")
util.AddNetworkString("rhud_ks-init")
util.AddNetworkString("rhud_ks-add")
util.AddNetworkString("rhud_ks-dc")
util.AddNetworkString("rhud_ks-reset")
util.AddNetworkString("rhud_ks-new")
util.AddNetworkString("rhud_ks-exclaim")

util.AddNetworkString("rhud_karma-init")
util.AddNetworkString("rhud_rate")
util.AddNetworkString("rhud_karma-sendall")

hook.Add("CanDrive", "rhud_blockDrivingProps", function(ply, ent)
	net.Start("rhud_nodrive")
	net.Send(ply)
	return false
end)
