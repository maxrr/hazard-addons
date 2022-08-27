include("shared.lua")

-- freerem = 1

local loading = 1
local ntitle = "LOADING"
local ncol = Color(255, 255, 255)
rsig_nrainbow = false
local checkmarkmat = Material("icon16/accept.png")
local id 

local function checkLoad()
	if IsValid(LocalPlayer()) and LocalPlayer() != nil then
		if LocalPlayer():SteamID64() != nil then
			id = LocalPlayer():SteamID64()
			if Titles != nil then
				if Titles[id] != nil then
					if Titles[id].color != nil and Titles[id].title != nil then
						ntitle = Titles[id].title
						ncol = Titles[id].color
						if Titles[id].rainbow == "true" then rsig_nrainbow = true end
						loading = 0
					else
						timer.Simple(3, checkLoad)
					end
				else
					timer.Simple(3, checkLoad)
				end
			else
				timer.Simple(3, checkLoad)
			end
		else
			timer.Simple(3, checkLoad)
		end
	end
end

hook.Add("InitPostEntity", "setFreeremToAppropriateValue", function()
	checkLoad()
end)

closePath = Material("icon16/cancel.png")

net.Receive("rsig_cl_menu", function(len)
	local rainbow = false
	local frame = vgui.Create("DFrame")
	frame:SetSize(306, 460)
	frame:Center()
	frame:SetTitle("Change Title")
	frame:SetDraggable(true)
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h + 2, Color(60, 60, 60))
		draw.RoundedBox(8, 0, 0, w, 24, Color(40, 40, 40))
		draw.RoundedBox(0, 0, 19, w, 6, Color(40, 40, 40))

		draw.SimpleText("Text", "PlayerCustomizableTitleMenuFont", 23, 35, Color(255, 255, 255))
		draw.RoundedBox(0, 25, 52, w - 50, 2, Color(66, 155, 244))

		draw.SimpleText("Color", "PlayerCustomizableTitleMenuFont", 25, 90, Color(255, 255, 255))
		draw.RoundedBox(0, 25, 107, w - 50, 2, Color(66, 155, 244))

		draw.SimpleText("Premium", "PlayerCustomizableTitleMenuFont", 26, 350, Color(255, 255, 255))
		draw.RoundedBox(0, 25, 350 + (107 - 90), w - 50, 2, Color(66, 155, 244))

		draw.RoundedBox(4, 25, 350 + (107 - 90) + 8, 20, 20, Color(40, 40, 40))
		draw.SimpleText("Rainbow", "DermaDefault", 50, 350 + (107 - 90) + 17, Color(255, 255, 255), 0, 1)

		-- if freerem > 0 then draw.SimpleText("You have " .. freerem .. " free title change(s) remaining.", "DermaDefaultBold", w / 2, 363, Color(66, 155, 244), 1, 1) end
	end

	local close = vgui.Create("DButton", frame)
	close:SetSize(16, 16)
	close:SetPos(frame:GetWide() - 20, 4)
	close:SetText("")
	close.DoClick = function()
		frame:Close()
	end
	close.Paint = function(self, w, h)
		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(closePath)
		surface.DrawTexturedRect(0, 0, 16, 16)
	end

	local title = vgui.Create("DTextEntry", frame)
	title:SetText(Titles[id].title)
	title:SetSize(256, 20)
	title:SetPos(25, 60)

	local color = vgui.Create("DColorMixer", frame)
	color:SetPalette(false)
	color:SetAlphaBar(false)
	color:SetWangs(true)
	color:SetColor(Titles[id].color)
	color:SizeToContents()
	color:SetPos(25, 115)

	local rainbowbtn = vgui.Create("DButton", frame)
	rainbowbtn:SetSize(16, 16)
	rainbowbtn:SetText("")
	rainbowbtn:SetPos(27, 350 + (107 - 90) + 10)
	rainbowbtn.Paint = function(self, w, h)
		if rainbow == true then
			surface.SetDrawColor(Color(255, 255, 255))
			surface.SetMaterial(checkmarkmat)
			surface.DrawTexturedRect(0, 0, 16, 16)
		end
	end
	rainbowbtn.DoClick = function()
		if rainbow == true then
			rainbow = false
		else
			local f = 0
			for k, v in pairs(rsig.advanced) do
				if LocalPlayer():GetUserGroup() == v then
					f = 1
					break
				end
			end
			if f == 1 then
				rainbow = true
			else
				local color = Color(48, 179, 255)
				chat.AddText(color, "[", Color(255, 255, 255), "R-TITLES", color, "]", Color(255, 255, 255), " To use this, you need to purchase Premium or Premium+ from our website: ", color, "www.hgaming.net", Color(255, 255, 255), ".")
			end
		end
	end

	local confirm = vgui.Create("DButton", frame)
	confirm:SetSize(256, 30)
	confirm:SetPos(24, frame:GetTall() - confirm:GetTall() - 25)
	confirm:SetText("")

	-- if freerem < 1 then confirm:SetEnabled(false) end

	confirm.Paint = function(self, w, h)
		local drawcolor = Color(66, 155, 244)
		if confirm:GetDisabled() == true then drawcolor = Color(80, 80, 80) end

		draw.RoundedBox(4, 1, 0, w - 2, h, drawcolor)
		draw.SimpleText("Confirm", "DermaDefault", w / 2, h / 2 - 1, Color(20, 20, 20), 1, 1)
	end
	confirm.DoClick = function()
		local dispcolor = Color(48, 179, 255)
		if string.len(title:GetValue()) < 20 then
			local info = {}
			info.title = title:GetValue()
			info.color = color:GetColor()
			info.rainbow = rainbow

			ntitle = info.title

			net.Start("rsig_cl_change")
			net.WriteTable(info)
			net.SendToServer()

			if rainbow == true then
				rsig_nrainbow = true
				chat.AddText(dispcolor, "[", Color(255, 255, 255), "R-TITLES", dispcolor, "]", Color(255, 255, 255), " Your title has been changed to: ", title:GetValue(), dispcolor, " (with rainbow mode enabled)", Color(255, 255, 255), ".")
			else
				chat.AddText(dispcolor, "[", Color(255, 255, 255), "R-TITLES", dispcolor, "]", Color(255, 255, 255), " Your title has been changed to: ", info.color, title:GetValue())
				ncol = info.Color
			end
			frame:Close()
		else
			chat.AddText(dispcolor, "[", Color(255, 255, 255), "R-TITLES", dispcolor, "]", Color(255, 255, 255), " Your title must be less than 20 characters. No changes have been made. ")
		end
	end
end)

surface.CreateFont( "TitleVendorTopLine3DFont", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 80,
	weight = 1000,
	shadow = false,
	outline = false,
} )

surface.CreateFont( "TitleVendorBottomLine3DFont", {
	font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 30,
	weight = 1000,
	shadow = false,
	outline = false,
} )

surface.CreateFont( "3DTitleCurrentFont", {
    font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 40,
    weight = 500,
    shadow = false,
    outline = false,
} )

surface.CreateFont( "3DTitleCurrentTextFont", {
    font = "DermaLarge", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 20,
    weight = 500,
    shadow = false,
    outline = false,
} )

timer.Create("updateNPCTitleStats", 2, 0, function()
	if loading == 0 then
		ncol = Titles[id].color
		ntitle = Titles[id].title
	else
		checkLoad()
	end
end)

function ENT:Draw()
	id = LocalPlayer():SteamID64()
	self:DrawModel()

	local offset = Vector(0, 0, 4)
	-- if tonumber(freerem) > 0 then offset = Vector(0, 0, 3) end

	local headVector, headAngle = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Head1"))
	local tang = (LocalPlayer():GetPos() - self:GetPos()):Angle()
	local ang = Angle(0, tang.y + 180, 0)
	local pos = headVector + Vector(0, 0, 12.5) + offset

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	cam.Start3D2D(pos, ang, 0.10)
		draw.SimpleText("Title Vendor", "TitleVendorTopLine3DFont", 0, 0, Color(255, 255, 255), 1, 1)
		-- if freerem > 0 then draw.SimpleText("You have " .. freerem .. " free title change(s) remaining.", "TitleVendorBottomLine3DFont", 0, 50, Color(255, 255, 255), 1, 1) end
		local dcl = ncol
		if rsig_nrainbow == true then
			dcl = HSVToColor(rsig_hue, 1, 1)
		end
		draw.SimpleText("YOUR TITLE:", "3DTitleCurrentTextFont", 0, -75, Color(255, 255, 255), 1, 1)
		draw.SimpleText(ntitle, "3DTitleCurrentFont", 0, -50, dcl, 1, 1)
		draw.SimpleText("TIMMY THE TITLE MAN", "3DTitleCurrentFont", 0, 50, Color(255, 255, 255), 1, 1)
	cam.End3D2D()
end
