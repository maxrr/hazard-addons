-- I exist!
local cleanMaterial = Material("models/debug/debugwhite")

surface.CreateFont( "3DHUDFont4", {
	font = "Roboto Light", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 85,
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

local function DrawName2( ply )
	if ( !IsValid( ply ) ) then return end
	if ( !ply:Alive() ) then return end
	if rhud_g_screenshotmode then return end 

	local distance = LocalPlayer():GetPos():Distance( ply:GetPos() )

	if distance < 6000 then
		if ply:GetNWBool("rbuild_enabled", false) then

			local targetPos = ply:GetPos()

	        local tpos = (LocalPlayer():GetPos() - ply:GetPos())
			local tang = tpos:Angle()
			local ang = Angle(0, tang.y + 180, 0)
			local pos = targetPos + ang:Forward() * -50 + Vector(0, 0, 50)

			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )

			cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.05	 )
				render.OverrideDepthEnable(true, true)
				local w, h = 470, 100
				draw.RoundedBox(20, -(w/2), -(h/2), w, h, Color(80, 255, 80))
				render.OverrideDepthEnable(true, false)
				draw.SimpleText("BUILD MODE", "3DHUDFont4", 0, 0, Color(20, 20, 20), 1, 1)
				render.OverrideDepthEnable(false, false)
			cam.End3D2D()

		end
	end
end

hook.Add( "PostPlayerDraw", "rhud_float2", DrawName2 )
