
//s
RLVCContext = RLVCContext or {false, nil, 0, nil}
local RLVCMats = RLVCMats or {}
RLVCMats.prox = Material("icon16/transmit_blue.png")
RLVCMats.global = Material("icon16/world.png")

RLVCMats.global = Material("rl_voicechannels_mats/global.png")
RLVCMats.prox = Material("rl_voicechannels_mats/prox.png")

local iconPanelY = 7 - 25
local iconPanelShouldY = 7 - 25

local frameWidth = 30
local frameWidthShould = 30

local menuOpen = false

local function betterRound(num)
    //if num < 1 and num > -1 then return math.floor(num) else return num end
    return math.Round(num, 3)
end



/*local function startDrawing()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(frameWidth, 30)
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame.Paint = function(self, w, h)
        if firstGo != nil and firstGo[2] != nil then
            local shouldDrawRightSides = true
            local fx, fy = firstGo[2]:GetPos()

            if frameWidth >= 36 then shouldDrawRightSides = false end

            local text = string.upper(RLVC.currentChannel) .. " VOICE CHAT"
            surface.SetFont("HUDSmallNumberDisplay")
            local textWidth, _ = surface.GetTextSize(text)
            if menuOpen then frameWidthShould = textWidth + 30 + 16 else frameWidthShould = 30 end
            frameWidth = betterRound(Lerp(RealFrameTime() * 10, frameWidth, frameWidthShould))

            self:SetSize(frameWidth, 30)

            local totalWidth = frameWidth + 6 + firstGo[2]:GetWide()

            //self:SetPos(fx - frameWidth - 6, ScrH() - 40)
            self:SetPos(ScrW() / 2 - totalWidth / 2, ScrH() - 40)
            RLVCContext[3] = totalWidth
            //self:AlignBottom(10)
            //self:AlignRight(ScrW() / 2 + 3)

            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30))
            draw.RoundedBoxEx(8, 0, 0, 30, h, Color(20, 20, 20), true, shouldDrawRightSides, true, shouldDrawRightSides)
            draw.SimpleText(text, "HUDSmallNumberDisplay", 37, h / 2 - 1, Color(255, 255, 255), 0, 1)
        end
    end

    RLVCContext[2] = frame

    local iconPanel = vgui.Create("DPanel", frame)
    iconPanel:SetSize(16, 40)
    iconPanel:SetPos(7, 7)
    iconPanel.Paint = function(self, w, h)
        iconPanelY = Lerp(RealFrameTime() * 10, iconPanelY, iconPanelShouldY)
        if RLVC.currentChannel == "proximity" then
            iconPanelShouldY = 7
        else
            iconPanelShouldY = 7 - 25
        end

        local x, _ = self:GetPos()
        self:SetPos(x, iconPanelY)

        surface.SetDrawColor(Color(255, 255, 255))
        surface.SetMaterial(RLVCMats.prox)
        surface.DrawTexturedRect(0, 0, 16, 16)
        surface.SetMaterial(RLVCMats.global)
        surface.DrawTexturedRect(0, h - 16, 16, 16)
    end

    local button = vgui.Create("DButton", g_ContextMenu)
    button:SetPos((ScrW() - 111) / 2, ScrH() - 34)
    button:SetSize(frame:GetSize())
    button:SetText("")
    button.DoClick = function()
        net.Start("rlvc_setchannel")
        net.SendToServer()
    end
    button.Paint = function(self, w, h)
        self:SetSize(frame:GetSize())
        self:SetPos(frame:GetPos())
        //draw.RoundedBox(8, 0, 0, w, h, Color(0, 255, 0, 100))
    end

    RLVCContext[4] = button
end

if RLVCContext[1] == true then
    RLVCContext[2]:Remove()
    RLVCContext[4]:Remove()
    startDrawing()
end

hook.Add("HUDPaint", "rlvc_startDrawing", function()
    if RLVCContext[1] == false then
        RLVCContext[1] = true
        startDrawing()
    end

    //draw.RoundedBox(0, ScrW() / 2 - 40, 0, 2, ScrH(), Color(255, 0, 0))
    //draw.RoundedBox(0, ScrW() / 2 - 2, 0, 4, ScrH(), Color(255, 0, 0))
    //draw.RoundedBox(0, ScrW() / 2 + 38, 0, 2, ScrH(), Color(255, 0, 0))
end)

RLVC.ContextOpen = false

hook.Add("OnContextMenuOpen", "rlvc_open", function() menuOpen = true; RLVC.ContextOpen = true end)
hook.Add("OnContextMenuClose", "rlvc_close", function() menuOpen = false; RLVC.ContextOpen = false end)
*/
