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

if not CLIENT then return end

surface.CreateFont( "rl_buttonbarFont", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 16,
	weight = 1000,
	antialias = true,
} )

// HELPERS
local pow = math.pow
local function outCubic(t, b, c, d)
  t = t / d - 1
  return c * (pow(t, 3) + 1) + b
end
local function betterRound(num)
    //if num < 1 and num > -1 then return math.floor(num) else return num end
    return math.Round(num, 4)
end
local function vTc(v, a)
	return Color(v.x, v.y, v.z, a)
end

// VARS
g_bbCreatedAlready = g_bbCreatedAlready or false
local PANEL = {}
local iExpandSpeed = 0.4
local iContractSpeed = 0.4
local iSwapIconSpeed = 0.5
local iTotalPanels

local iIconPanelMinimum = 8
local iIconPanelMaximum = iIconPanelMinimum - 33

local bIsContextMenuOpen = false

// PANEL
function PANEL:Init()
	self.iIconPanelYCurrent = iIconPanelMinimum
	self.iIconPanelYShould = iIconPanelMinimum
	self.vThumbColorCurrent = Vector(20, 20, 20)
	self.vThumbColorShould = Vector(20, 20, 20)
	self.bIsForcedOpen = false

    self:TDLib():ClearPaint()
    self:Dock(RIGHT)
    self:SetSize(g_bbMasterPanel:GetTall(), g_bbMasterPanel:GetTall())
    self:DockMargin(5, 0, 0, 0)
    self.Paint = function(s, w, h)
		if rhud_g_screenshotmode then return end 
	
        local bFullRound = w <= 34
        local iAlpha = !bFullRound and 255 or 0
		if self.vThumbColorShould:IsEqualTol(self.vThumbColorShould, 0.2) then self.vThumbColorCurrent = Lerp(RealFrameTime() * 10, self.vThumbColorCurrent, self.vThumbColorShould) end
        draw.RoundedBoxEx(8, 0, 0, h, h, vTc(self.vThumbColorCurrent), true, bFullRound, true, bFullRound)
        draw.RoundedBoxEx(8, h, 0, w - h, h, Color(30, 30, 30, iAlpha), false, true, false, true)
    end

    self.LeftNest = vgui.Create("DPanel", self):TDLib():ClearPaint()
    self.LeftNest:SetPos(0, 0)
    self.LeftNest:SetSize(32, 32)

	self.IsTopCurrentIcon = true
    self.IconPanel = vgui.Create("DPanel", self.LeftNest):TDLib():ClearPaint()
    self.IconPanel:SetSize(16, 48)
    self.IconPanel:SetPos(8, iIconPanelMinimum)
    self.IconPanel:On("Paint", function(s, w, h)
		if rhud_g_screenshotmode then return end 
		
		self.iIconPanelYCurrent = Lerp(RealFrameTime() * 10, self.iIconPanelYCurrent, self.iIconPanelYShould)
		s:SetPos(8, self.iIconPanelYCurrent)

        surface.SetDrawColor(255, 255, 255)
        if self.TopIcon then
            surface.SetMaterial(self.TopIcon)
            surface.DrawTexturedRect(0, 0, 16, 16)
        end
        if self.BottomIcon then
            surface.SetMaterial(self.BottomIcon)
            surface.DrawTexturedRect(0, h - 16, 16, 16)
        end
    end)

    self.NameLabel = vgui.Create("DLabel", self):TDLib()
    self.NameLabel:SetPos(40, 0)
    self.NameLabel:CenterVertical(0.49)
    self.NameLabel:SetFont("rl_buttonbarFont")
    self.NameLabel:SetText("")
    self.NameLabel:SetColor(Color(255, 255, 255, 0))
	self.NameLabel.Paint = function(s, w, h)
		if self.MarkupParsed then
			self.MarkupParsed:Draw(0, h/2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	self.ClickPanel = vgui.Create("DButton", g_ContextMenu):TDLib():ClearPaint()
	self.ClickPanel:SetSize(self:GetSize())
	self.ClickPanel:SetText("")
	self.ClickPanel:On("Paint", function(s)
		local x1, y1 = self:GetPos()
		local x2, y2 = g_bbMasterPanel:GetPos()
		s:SetSize(self:GetSize())
		s:SetPos(x1 + x2, y1 + y2)
	end)
	self.ClickPanel.DoClick = function()
		//self:ToggleIcon()
		if self.CallbackFunc then self:CallbackFunc(self) end
	end
end

function PANEL:Think()
    if self.expandAnim then self.expandAnim:Run() end
    if self.contractAnim then self.contractAnim:Run() end
    if self.swapiconAnim then self.swapiconAnim:Run() end
end

function PANEL:Expand(anim, det, fin)
    self:SetWidth((fin - self:GetWide()) * det + self:GetWide())
    g_bbMasterPanel:RedoWidth()
    g_bbMasterPanel:InvalidateLayout(true)
end

function PANEL:StartExpand()
	if self.contractAnim then
		self.contractAnim:Stop()
		self.contractAnim = nil
	end
	self.expandAnim = Derma_Anim("ExpandPanel", self, self.Expand)
	self.expandAnim:Start(iExpandSpeed, self.ProperWidth)
end

function PANEL:Contract(anim, det, fin)
    self:SetWidth(self:GetWide() - (self:GetWide() - fin) * det)
    g_bbMasterPanel:RedoWidth()
    g_bbMasterPanel:InvalidateLayout(true)
end

function PANEL:StartContract(to)
	if self.expandAnim then
		self.expandAnim:Stop()
		self.expandAnim = nil
	end
	self.contractAnim = Derma_Anim("ContractPanel", self, self.Contract)
	self.contractAnim:Start(iContractSpeed, to)
end

function PANEL:ForceOpen(open)
	if type(open) == "boolean" then
		if open then
			if !bIsContextMenuOpen then
				self:StartExpand()
			end
		else
			if !bIsContextMenuOpen then
				timer.Simple(0, function()
					self:StartContract(32)
				end)
			end
		end
		self.bIsForcedOpen = open
	end
end

function PANEL:SetIcon(top)
	if type(top) == "boolean" then
		self.IsTopCurrentIcon = top
		if top then
			self.iIconPanelYShould = iIconPanelMinimum
		else
			self.iIconPanelYShould = iIconPanelMaximum
		end
	else
		ErrorNoHalt("Tried to set buttonbar panel's icon boolean without a boolean.")
	end
end

function PANEL:ToggleIcon()
	self:SetIcon(!self.IsTopCurrentIcon)
end

function PANEL:SwitchToColor(r, g, b)
    self.vThumbColorShould = Vector(r, g, b)
end

function PANEL:GetProperWidth()
    local iTotalW = 0
    for k, v in pairs(self:GetChildren()) do
        iTotalW = iTotalW + v:GetWide()
    end
    iTotalW = iTotalW + #self:GetChildren() * 8
    return iTotalW
end

function PANEL:UpdateText(sText)
	if sText then
		self:Setup(sText)
		timer.Simple(0, function()
			if bIsContextMenuOpen or self.bIsForcedOpen then
				if self.ProperWidth > self:GetWide() then
					self:StartExpand()
				elseif self.ProperWidth < self:GetWide() then
					self:StartContract(self.ProperWidth)
				end
			end
		end)
	end
end

function PANEL:Setup(sText, sIcon1, sIcon2)
    if sIcon1 then self.TopIcon = Material(sIcon1) end
    if sIcon2 then self.BottomIcon = Material(sIcon2) end

	if sText then
		local sTextVanilla = string.gsub(sText, "<.->", "")
	    self.NameLabel:SetText(sTextVanilla)
	    self.NameLabel:SizeToContentsX()
		self.MarkupParsed = markup.Parse("<font=rl_buttonbarFont>" .. sText .. "</font>")
	end

    timer.Simple(0, function()
        self.ProperWidth = self:GetProperWidth()
    end)
end

vgui.Register("rlBarButton", PANEL, "DPanel")

function createMasterPanel()
    g_bbCreatedAlready = true
    g_bbMasterPanel = vgui.Create("DPanel"):TDLib():ClearPaint()
    g_bbMasterPanel:ParentToHUD()
    g_bbMasterPanel:SetHeight(32)
    g_bbMasterPanel:SetPos(0, ScrH() - 40)
    g_bbMasterPanel:CenterHorizontal(0.5)

    g_bbMasterPanel.RedoWidth = function()
        local tChildren = g_bbMasterPanel:GetChildren()
        local iMl, iMt, iMr, iMb = tChildren[1]:GetDockMargin()
        local iTotalW = iMl * (#tChildren - 1)

        for k, v in pairs(tChildren) do
            iTotalW = iTotalW + v:GetWide()
        end

        g_bbMasterPanel:SetWidth(iTotalW)
        g_bbMasterPanel:CenterHorizontal(0.5)
    end

    hook.Call("buttonbarMasterReady")

    iTotalPanels = #g_bbMasterPanel:GetChildren()

    g_bbMasterPanel:RedoWidth()
end

if g_bbCreatedAlready == true then
	if g_bbMasterPanel ~= nil then
		for k, v in pairs(g_bbMasterPanel:GetChildren()) do
			v.ClickPanel:Remove()
			v:Remove()
		end
	    g_bbMasterPanel:Remove()
	end
    createMasterPanel()
end

// HOOKS
hook.Add("InitPostEntity", "bbCreateMasterPanel", createMasterPanel)
hook.Add("OnContextMenuOpen", "bbContextOpen", function()
	bIsContextMenuOpen = true
	if g_bbMasterPanel ~= nil then
	    for k, v in pairs(g_bbMasterPanel:GetChildren()) do
			if !v.bIsForcedOpen then
				v:StartExpand()
			end
	    end
	end
end)
hook.Add("OnContextMenuClose", "bbContextClose", function()
	bIsContextMenuOpen = false
	if g_bbMasterPanel ~= nil then
	    for k, v in pairs(g_bbMasterPanel:GetChildren()) do
			if !v.bIsForcedOpen then
				v:StartContract(32)
			end
	    end
	end
end)
