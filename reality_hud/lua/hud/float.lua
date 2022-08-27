local width
local height

local adminRanks = {
	["owner"] = true,
	["ownerassistant"] = true,
	["superadmin"] = true,
	["admin"] = true,
	["moderator"] = true,
	//["user"] = true,
}

local playersTalking = {}

hook.Add("PlayerStartVoice", "rhud_startvoice", function(ply)
	if ply == nil then return end
	playersTalking[ply] = true
end)

hook.Add("PlayerEndVoice", "rhud_stopvoice", function(ply)
	if ply == nil then return end
	playersTalking[ply] = nil
end)

surface.CreateFont( "3DHUDFont2", {
	font = "Roboto Light", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 128,
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

surface.CreateFont( "3DHUDFont3", {
	font = "Roboto Light", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 100,
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

local micMat = Material("r_hud/mic.png")
local mutedMat = Material("r_hud/mic_muted.png")
local chatMat = Material("r_hud/chat.png")
local starMat = Material("r_hud/star.png")
local skullMat = Material("r_hud/skull_big.png")
local worldMat = Material("r_hud/globe.png")
local proxMat = Material("r_hud/proximity.png")

if not ConVarExists("rhud_drawself") then
	CreateClientConVar("rhud_drawself", "0", true)
end
local bShouldDrawSelf = GetConVar("rhud_drawself"):GetBool()
timer.Create("rhud_cl_drawself_create", 5, 0, function()
	bShouldDrawSelf = GetConVar("rhud_drawself"):GetBool()
end)

if not ConVarExists("rhud_screenshotmode") then 
	CreateClientConVar("rhud_screenshotmode", "0", true)
end 
rhud_g_screenshotmode = GetConVar("rhud_screenshotmode"):GetBool()
timer.Create("rhud_cl_screenshotmode_create", 5, 0, function()
	rhud_g_screenshotmode = GetConVar("rhud_screenshotmode"):GetBool()
	if LocalPlayer() and IsValid(LocalPlayer()) and LocalPlayer():Alive() then 
		if LocalPlayer():GetActiveWeapon() and IsValid(LocalPlayer():GetActiveWeapon()) then 
			if LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" then 
				rhud_g_screenshotmode = true
			end 
		end 
	end 
end)

local function DrawName( ply )
	local headVector
	local headAngle
	if ply:LookupBone("ValveBiped.Bip01_Head1") != nil then
		headVector, headAngle = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
		headVector = headVector + Vector(0, 0, 0)
	else
		headVector = ply:GetPos() + Vector(0, 0, 60)
	end
	if ( !IsValid( ply ) ) then return end
	if ( ply == LocalPlayer() and not bShouldDrawSelf ) then return end
	if rhud_g_screenshotmode then return end 
	if ( !ply:Alive() ) then return end

	local distance = LocalPlayer():GetPos():Distance( ply:GetPos() )

	if distance < 600 then

		local function randString(seed)
			seed = seed or math.floor(os.time() / 2)
			rlh_lastseed 		= rlh_lastseed 		  or ""
			rlh_lastseed_result = rlh_lastseed_result or ""
			if seed == rlh_lastseed then return rlh_lastseed_result end
			rlh_lastseed = seed

			local len = string.Explode("", tostring(seed))
			local last = len[#len] * 2
			local alphabet = string.Explode("", "abcdefghijklmnopqrstuvwxyz1234567890")
			local assemble = {}
			for i = 0, tonumber(last) do
				table.insert(assemble, table.Random(alphabet)[1])
			end
			rlh_lastseed_result = table.concat(assemble)
			return rlh_lastseed_result
		end

		local offset = Vector( 0, 0, 0 )
		local tang = (LocalPlayer():GetPos() - ply:GetPos()):Angle()
		local ang = Angle(0, tang.y + 180, 0)
		local pos = headVector + Vector(0, 0, 18)
		//local pos = ply:GetPos() + Vector(0, 0, 70)

        local newhp = math.Clamp(ply:Health() * 5, 0, 500)
        local newarmor = math.Clamp(ply:Armor() * 5, 0, 500)
		local nick = ply:Nick()
		//nick = randString()

		width, height = draw.SimpleText(string.upper(nick), "3DHUDFont2",0, 0, Color(200, 200, 200, 0), 1, 1)
		width = width + 20
		height = height + 20

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		/*local drawdata, x, y, visible

		cam.Start3D()
			drawdata = pos:ToScreen()
			x, y, visible = drawdata.x, drawdata.y, drawdata.visible
		cam.End3D()

		local trace = util.TraceLine({
			start = LocalPlayer():EyePos(),
			endpos = ply:EyePos(),
		})
		if trace.HitWorld == true or !(trace.Entity:IsPlayer()) then visible = false end

		cam.Start2D()
			if ply != LocalPlayer() then
				if visible then
					//local w, h = distance * .5 * 2, distance * .5 * 2
					local ratio = math.sqrt(1000 / distance)

					local opac
					if distance > 400 then opac = math.Clamp(-(distance - 600), 0, 255) else opac = 255 end

					local tw, _ = draw.SimpleText(ply:Nick(), "3DHUDFont2", 0, 0, Color(0, 0, 0, 0))
					//local w = math.min(tw, tw * ratio)
					//local h = math.min(60, 60 * ratio)
					local w = .5 * math.Clamp(tw * ratio, tw * 0.9, tw)
					local h = .5 * math.Clamp(90 * ratio, 90 * 0.9, 90)

					draw.RoundedBox(8, x - w / 2, y - h, w, h, Color(20, 20, 20, opac))
				end
			end
		cam.End2D()*/

		/*cam.Start3D2D(pos, Angle( 0, ang.y, 90 ), 0.2)
			if ply != LocalPlayer() then
				local ratio = 500 / distance
				local initw, inith, initround = 220, 60, 20
				local w = math.Clamp(initw * ratio, initw, initw * 1.5)
				local h = math.Clamp(inith * ratio, inith, inith * 1.5)
				local round = math.Clamp(initround * ratio, initround, initround * 1.5)
				draw.RoundedBox(round, 0, 0, w, h, Color(20, 20, 20))
			end
		cam.End3D2D()*/

		local function drawRectFromTopRight(r, x, y, w, h, c)
			x = x - w
			draw.RoundedBox(r, x, y, w, h, c)
		end

		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.02 )
			if visible then
				draw.RoundedBox(20, -100, -100, 200, 200, Color(20, 20, 20))
			end
			height = height + 10
			//draw.RoundedBox(20, (0 - width/2 - 15), (0 - height/2 + 145), width + 30, height + 10, Color(20, 20, 20))
			drawRectFromTopRight(20, (0 + width/2 - 100 + 30), (0 - height/2 + 150), width + 40, height, Color(20, 20, 20))
			draw.RoundedBox(20, (0 + width/2 + 10 - (100 - (height + 10) / 4)), (0 - height/2 + 150), height, height, Color(20, 20, 20))
			draw.SimpleText(string.upper(nick), "3DHUDFont2", -95, 150, Color(200, 200, 200), 1, 1)
			height = height - 10
			local mic_opac = 255
			if !ply:IsMuted() then
				if playersTalking[ply] == true then
					local mic = ply:VoiceVolume()
					if mic > 0.008 then
						mic_opac = math.Clamp(mic * 500, 20, 255);
						draw.RoundedBox(20, width / 2 + 30 + 105, 0 - height / 2 + 145, 155, 155, Color(20, 20, 20))
						surface.SetDrawColor(Color(255, 255, 255, mic_opac))
						surface.SetMaterial(micMat)
						surface.DrawTexturedRect(width / 2 + 30 + (150 - 128) / 2 + 3 + 105, 0 - height / 2 + 145 + (150 - 128) / 2, 128, 128)
					end
				end
			else
				draw.RoundedBox(20, width / 2 + 30 + 105, 0 - height / 2 + 145, 155, 155, Color(20, 20, 20))
				surface.SetDrawColor(Color(255, 60, 60))
				surface.SetMaterial(mutedMat)
				surface.DrawTexturedRect(width / 2 + 30 + (150 - 128) / 2 + 3 + 105, 0 - height / 2 + 145 + (150 - 128) / 2, 128, 128)
			end

			if ply:IsTyping() then
				draw.RoundedBox(20, 0 - width / 2 - 30 - 128 - 30 - 100, 0 - height / 2 + 145, 155, 155, Color(20, 20, 20))
				surface.SetDrawColor(Color(255, 255, 255))
				surface.SetMaterial(chatMat)
				surface.DrawTexturedRect(0 - width / 2 - 30 - (150 - 128) / 2 - 6 - 128 - 100, 0 - height / 2 + 148 + (150 - 128) / 2, 128, 128)
			end

			local healthColor = Color(255, 80, 80)
			local health = tostring(ply:Health())
			local fixedHealth = math.Clamp(ply:Health() * 5, 0, 500)
			if ply:GetNWBool("rbuild_enabled", false) == true then healthColor = Color(80, 255, 80); fixedHealth = 500; health = "" end

			draw.RoundedBox(20, -250, 260, 500, 60, Color(20, 20, 20))
			draw.RoundedBox(20, -250, 260, fixedHealth, 60, healthColor)
			draw.SimpleText(health, "3DHUDFont3", 280, 287, Color(255, 255, 255), 0, 1)
            if fixedHealth <= 480 then draw.RoundedBox(0, fixedHealth - 270, 260, 20, 60, healthColor) end

			if newarmor > 0 then
				draw.RoundedBox(20, -250, 340, 500, 60, Color(20, 20, 20))
				draw.RoundedBox(20, -250, 340, newarmor, 60, Color(80, 80, 255))
				draw.SimpleText(ply:Armor(), "3DHUDFont3", 280, 367, Color(255, 255, 255), 0, 1)
                if newarmor <= 480 then draw.RoundedBox(0, newarmor - 270, 340, 20, 60, Color(80, 80, 255)) end
			end

			local rankWidth, rankHeight = draw.SimpleText(string.upper(team.GetName(ply:Team())), "3DHUDFont2", 0, 0, Color(200, 200, 200, 0), 1, 1)

			/*if adminRanks[ply:GetUserGroup()] == true then
				draw.RoundedBox(20, 0 - (rankWidth + 60) / 2 - 100, -75, 300, rankHeight - 30, Color(20, 20, 20))
				surface.SetDrawColor(team.GetColor(ply:Team()))
				surface.SetMaterial(starMat)
				surface.DrawTexturedRect(0 - (rankWidth + 60) / 2 - 113, -92, 128, 128)
			end*/

			draw.RoundedBox(20, 0 - (rankWidth + 60) / 2, -90, rankWidth + 60, rankHeight + 1, team.GetColor(ply:Team()))
			draw.SimpleText(string.upper(team.GetName(ply:Team())), "3DHUDFont2", 0, -25, Color(20, 20, 20), 1, 1)

			/*if rhud_ks != nil then
				if rhud_ks[LocalPlayer():SteamID64()] != nil and rhud_ks[ply:SteamID64()] != nil then
					local actual = rhud_ks[ply:SteamID64()]
					local tw3, th3 = draw.SimpleText(actual, "3DHUDFont2", 0, 0, Color(0, 0, 0, 0))

					draw.RoundedBox(20, (rankWidth + 60) / 2 + 15, -75, 110, rankHeight - 30, Color(20, 20, 20))
					draw.RoundedBox(20, (rankWidth + 60) / 2 + 15 + 90, -75, tw3 + 20, rankHeight - 30, Color(255, 255, 255))
					draw.RoundedBox(0, (rankWidth + 60) / 2 + 15 + 90, -75, 24, rankHeight - 30, Color(255, 255, 255))
					draw.SimpleText(actual, "3DHUDFont3", (rankWidth + 60) / 2 + 15 + 105, -75, Color(20, 20, 20), 0, 0)
					surface.SetDrawColor(Color(255, 255, 255))
					surface.SetMaterial(skullMat)
					surface.DrawTexturedRect((rankWidth + 60) / 2 + 28, -61, 64, 64)
				end
			end*/

			if ply.rlvc_channel != nil then
				//draw.SimpleText(ply.rlvc_channel, "3DHUDFont2", 0, -200, Color(20, 20, 20), 1, 1)
				local matToDraw = worldMat
				if ply.rlvc_channel == "proximity" then matToDraw = proxMat end
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(matToDraw)
				surface.DrawTexturedRect(0 + width/2 - 100 + 30 + 36, 0 - height/2 + 150 + 10, 128, 128)
			else
				ply.rlvc_channel = RLVC.defaultChannel
			end

		cam.End3D2D()
	end
end

hook.Add( "PostPlayerDraw", "DrawName", DrawName )
