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

hook.Add("InitPostEntity", "sendSignaturesInitMessage", function()
	local color = Color(48, 179, 255)
	timer.Simple(5, function()
		// chat.AddText(color, "[", Color(255, 255, 255), "R-TITLES", color, "]", Color(255, 255, 255), " Initialized. Welcome, ", color, LocalPlayer():Name(), Color(255, 255, 255), ".")
	end)
end)

Titles = Titles or {}
rsig = rsig or {}

surface.CreateFont( "PlayerCustomizableTitleFont", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 80,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "PlayerCustomizableTitleMenuFont", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
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
	additive = true,
	outline = false,
} )

rsig_hue = 0
hook.Remove("Think", "processHueForRainbowAndTitles", function()
	if rsig_hue > 360 then
		rsig_hue = 0
	else
		rsig_hue = rsig_hue + 0.6
	end
end)

timer.Create("processHueForRainbowAndTitles", 0.1, 0, function()
	if rsig_hue > 360 then
		rsig_hue = 0
	else
		rsig_hue = rsig_hue + 4
	end
end)

if not ConVarExists("rhud_drawself_title") then
	CreateClientConVar("rhud_drawself_title", "0", true)
end
local bShouldDrawSelfTitle = GetConVar("rhud_drawself_title"):GetBool()
timer.Create("rhud_cl_drawself_title_create", 5, 0, function()
	bShouldDrawSelfTitle = GetConVar("rhud_drawself_title"):GetBool()
end)

function DrawName( ply )
	local id = ply:SteamID64()
	local headVector
	local headAngle
	if ply:LookupBone("ValveBiped.Bip01_Head1") != nil then
		headVector, headAngle = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
		headVector = headVector + Vector(0, 0, 13)
	else
		headVector = ply:GetPos() + Vector(0, 0, 73)
	end

	if ( !IsValid( ply ) ) then return end
	if ( ply == LocalPlayer() and not bShouldDrawSelfTitle ) then return end
	if ( !ply:Alive() ) then return end
	if (Titles[id] == nil) then return end
	if rhud_g_screenshotmode then return end 

	local distance = LocalPlayer():GetPos():Distance( ply:GetPos() )

	if distance < 600 then

		local offset = Vector( 0, 0, -2.6 )
		local tang = (LocalPlayer():GetPos() - ply:GetPos()):Angle()
		local ang = Angle(0, tang.y + 180, 0)
		if ply == LocalPlayer() then
			ang = LocalPlayer():EyeAngles()
			ang = ang + Angle(0, 180, 0)
		end
		local pos = headVector + offset
		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.05 )
			local color = Titles[id].color
			if Titles[id].rainbow == "true" then
				color = HSVToColor(rsig_hue, 1, 1)
			end
			draw.SimpleText(Titles[id].title, "PlayerCustomizableTitleFont", 0, -200, color, 1, 4)
		cam.End3D2D()
	end
end

hook.Add("PostPlayerDraw", "DrawTitlesAboveHeads", DrawName)

net.Receive("rsig_update", function(len)
	local info = net.ReadTable()
	local id = net.ReadString()
	Titles[id] = info
	if id == LocalPlayer():SteamID64() then
		if info.rainbow == "true" then
			rsig_nrainbow = true
		else
			rsig_nrainbow = false
		end
	end
end)

net.Receive("rsig_config_upd", function(len)
	rsig = net.ReadTable()
end)

net.Receive("rsig_msg_update", function(len)
	local color = Color(48, 179, 255)
	local targ = net.ReadEntity()
	local tcl = team.GetColor(targ:Team())
	chat.AddText(color, "[", Color(255, 255, 255), "R-TITLES", color, "]", Color(255, 255, 255), " Title NPC(s) position has been saved by ", tcl, targ:Nick())
end)

net.Receive("rsig_msg_reload", function(len)
	local color = Color(48, 179, 255)
	chat.AddText(color, "[", Color(255, 255, 255), "R-TITLES", color, "]", Color(255, 255, 255), " Title NPC(s) have been reloaded.")
end)

net.Receive("rsig_msg_noperm", function(len)
	local color = Color(48, 179, 255)
	local tcl = team.GetColor(LocalPlayer():Team())
	chat.AddText(color, "[", Color(255, 255, 255), "R-TITLES", color, "] ", tcl, LocalPlayer():Nick(), Color(255, 255, 255), ", you do not have permission to perform this action.")
end)

net.Receive("rsig_admin_reset", function(len)
	local color = Color(48, 179, 255)
	local info = net.ReadTable()
	local tcl = team.GetColor(info.team)
	chat.AddText(color, "[", Color(255, 255, 255), "R-TITLES", color, "] ", tcl, info.nick, Color(255, 255, 255), "'s title has been reset by an admin.")
end)
