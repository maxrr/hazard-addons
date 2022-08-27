include("shared.lua")
-- include("fonts.lua")

surface.CreateFont( "TitleFont", {
	font = "DermaDefaultBold",
	size = 80,
	weight = 1500,
	antialias = true,
} )

surface.CreateFont( "ContentFont", {
	font = "DermaDefault",
	size = 40,
	weight = 500,
	antialias = true,
} )

local title = "Buildmode"
/*local content = [[
This should leave you with a basic
understanding about how Pointshop 2
works, and how to use crates. Feel
free to ask a veteran member about
more in-depth instructions within
Pointshop 2.

- Every 10 minutes, everyone gets a
random item. This could be a key,
or crate.

- If you have a corresponding key
AND crate, go into your inventory.

- Click on the crate. On the right side,
you will see that the "Open Crate"
option is now available.

- Click the "Open Crate" option.

- Loot.
]]*/
local content = [[
Buildmode is a great tool if you're 
just here for Sandbox, and don't want
to deal with people bothering you.

Type !build to go into buildmode,
type it again to exit.

While in buildmode, you cannot 
kill or damage other people.
]]

local parsetext = "<font=ContentFont>" .. content .. "</font>"
local width = 700
local parse = markup.Parse(parsetext, width - 40)
local height = parse:GetHeight() + 190

function ENT:Draw()
	self:DrawModel()
    self:DrawShadow(false)
	
	local pos = self:GetPos() + (self:GetAngles():Forward() * -0.1) + (self:GetAngles():Up() * 2) + (self:GetAngles():Right() * -0.05)
	local ang = self:GetAngles()

	ang:RotateAroundAxis(self:GetAngles():Up(), 90)

	cam.Start3D2D(pos, ang, 0.10)

        -- draw.RoundedBox(20, 0 - width / 2, 0 - height / 2, width, height, Color(255, 255, 255))
        draw.RoundedBox(20, 15 - width / 2, 15 - height / 2, width - 30, height - 28, Color(20, 20, 20))

        draw.RoundedBox(20, 15 - width / 2, 15 - height / 2, width - 30, 100, Color(30, 30, 30))
        draw.RoundedBox(0, 15 - width / 2, 15 - height / 2 + 88, width - 30, 16, Color(30, 30, 30))

        draw.SimpleText(title, "TitleFont", 0, 0 - height / 2 + 65, Color(255, 255, 255), 1, 1)

        draw.DrawText(content, "ContentFont", 0, 0 - height / 2 + 145, Color(255, 255, 255), 1, 1)

	cam.End3D2D()

end