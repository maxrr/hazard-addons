local mWand = Material("icon16/wand.png")
local mShield = Material("icon16/shield.png")
local mHeart = Material("icon16/heart.png")

local tRanks = {
	owner = mWand,
	ownerassistant = mWand,
	superadmin = mWand,

	admin = mShield,
	moderator = mShield,
	helper = mShield,

	premiumplus = mHeart,
	premium = mHeart,
}

// HELPERS //
local function drawCircle(x, y, r)
	local circle = {}
	for i = 1, 360 do
		circle[i] = {}
		circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end
	surface.DrawPoly(circle)
end

local pow = math.pow
local function outCubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end

// START //
local PANEL = {}
local tPlayerPanels = {}
local iRnd = 8

// PANEL //
local w, h = ScrW(), ScrH()
function PANEL:Init()
	self:TDLib()
	self:Dock(BOTTOM)
	self:SetSize(g_VoicePanelsMaster:GetWide(), 32)
	self:DockMargin(0, 5, 0, 0)
	self.Paint = function(s, w, h)
		if !IsValid(self.ply) then self:Remove(); return end
		// better performance to only call ::GetCorrectWidth() when needed, +~10-20 fps
		local iCw = 0
		if self.ShouldGetWidth then
			iCw = self:GetCorrectWidth()
		end

		local cCol = HSVToColor(self.ColorHue, self.ColorSat, self.ColorVal * self.ply:VoiceVolume() + 0.08) // HSVToColor(self.ColorHue, 1, self.ply:VoiceVolume() + .08)
		draw.RoundedBoxEx(iRnd, g_VoicePanelsMaster:GetWide() - iCw, 0, iCw - self.Avatar:GetWide(), h, cCol, true, false, true, false)
	end

    self.Avatar = vgui.Create("DPanel", self):TDLib()
	self.Avatar:SetSize(32, 32)
	self.Avatar:Dock(RIGHT)
    self.Avatar:AvatarMask(function(s, w, h)
		surface.DrawRect(0, 0, w - iRnd, h)
		surface.DrawRect(0, iRnd, w, h - iRnd * 2)
		drawCircle(w - iRnd, iRnd, iRnd)
		drawCircle(w - iRnd, h - iRnd, iRnd)
    end)

	self.RankIcon = vgui.Create("DPanel", self):TDLib():ClearPaint()
	self.RankIcon:Dock(RIGHT)
	self.RankIcon:SetSize(0, 0)
	self.RankIcon:DockMargin(0, 0, 0, 0)

	self.NameLabel = vgui.Create("DLabel", self):TDLib()
	self.NameLabel:Dock(RIGHT)
	self.NameLabel:CenterVertical(0.5)
	self.NameLabel:SetFont("RLVC_TalkingIndicator")
	self.NameLabel:SetColor(Color(255, 255, 255))
	self.NameLabel:DockMargin(10, 0, 8, 0)
end

function PANEL:GetCorrectWidth()
	local iDNLl, _, iDNLr, _ = self.NameLabel:GetDockMargin()
	local iDRIl, _, iDRIr, _ = self.RankIcon:GetDockMargin()
	local h = self:GetTall()
	local w = self.Avatar:GetWide()
	      w = w + self.NameLabel:GetWide()
		  w = w + iDNLl + iDNLr
		  w = w + self.RankIcon:GetWide()
		  w = w + iDRIl + iDRIr
	return w, h
end

function PANEL:Think()
	if self.fadeAnim then self.fadeAnim:Run() end
end

function PANEL:FadeOut(anim, det, dat)
	if anim.Finished then
		if IsValid(tPlayerPanels[self.ply]) then
			tPlayerPanels[self.ply]:Remove()
			tPlayerPanels[self.ply] = nil
			return
		end
		return
	end

	self:SetAlpha(outCubic(det, 255, -255, 1))
end

function PANEL:Setup(ply)
  ply = ply or LocalPlayer()
  if ply == nil or !IsValid(ply) then return end 

  self.ply = ply
  self.Avatar:SetPlayer(ply, 32)
  self.ColorHue, self.ColorSat, self.ColorVal = ColorToHSV(team.GetColor(ply:Team() or 1001))

	self.NameLabel:SetText(string.upper(ply:Nick()))
	self.NameLabel:SizeToContentsX()

	if tRanks[ply:GetUserGroup()] then
		self.RankIcon:Material(tRanks[ply:GetUserGroup()])
		self.RankIcon:SetSize(16, 16)
		self.RankIcon:DockMargin(0, self.RankIcon:GetWide() / 2, 8, self.RankIcon:GetWide() / 2)
		self.RankIcon:CenterVertical()
	end

  self:InvalidateLayout()
	self.ShouldGetWidth = 1
end

vgui.Register("rlVoicePanel", PANEL, "DPanel")

local function initializePanelMaster()
	if IsValid(g_VoicePanelsMaster) then g_VoicePanelsMaster:Remove() end

	g_VoicePanelsMaster = vgui.Create("DPanel"):TDLib():ClearPaint()
    g_VoicePanelsMaster:ParentToHUD()
	g_VoicePanelsMaster:SetSize(300, 600)
	g_VoicePanelsMaster:SetPos(ScrW() - g_VoicePanelsMaster:GetWide() - 10, ScrH() - g_VoicePanelsMaster:GetTall() - 130)
end

local function cleanInvalids()
	for k, v in pairs(tPlayerPanels) do
		if !IsValid(k) then
			GAMEMODE:PlayerEndVoice(k)
		end
	end
end
timer.Create("rlVoiceCleanse", 5, 0, cleanInvalids)

// HOOKS //
hook.Add("InitPostEntity", "rlVoiceCreateParent", initializePanelMaster)

hook.Add("PlayerStartVoice", "rlVoiceStart", function(ply)
	if !IsValid(g_VoicePanelsMaster) then return end
    GAMEMODE:PlayerEndVoice(ply)

	if IsValid(tPlayerPanels[ply]) then
		if tPlayerPanels[ply].fadeAnim then
			tPlayerPanels[ply].fadeAnim:Stop()
			tPlayerPanels[ply].fadeAnim = nil
		end

		tPlayerPanels[ply]:SetAlpha(255)
		return false
	end

	local panel = g_VoicePanelsMaster:Add("rlVoicePanel")
	panel:Setup(ply)

	tPlayerPanels[ply] = panel

	return false
end)

hook.Add("PlayerEndVoice", "rlVoiceEnd", function(ply)
	if IsValid(tPlayerPanels[ply]) then
		if tPlayerPanels[ply].fadeAnim then return end
		tPlayerPanels[ply].fadeAnim = Derma_Anim("FadeOut", tPlayerPanels[ply], tPlayerPanels[ply].FadeOut)
		tPlayerPanels[ply].fadeAnim:Start(2)
	end

	return false
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "rlVoiceClearPlayerOnDisc", function(bot, networkid, name, userid, reason)
	for k, v in pairs(tPlayerPanels) do
		if IsValid(k) then
			if k:UserID() == userid then
				tPlayerPanels[k] = nil
			end
		else
			tPlayerPanels[k] = nil
		end
	end
end)
