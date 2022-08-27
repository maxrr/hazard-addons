local shouldFrameWidth = 30
local frameWidth = 30

local alertWidth = 0
local alertWidthShould = 0

local iconPanelY = 7
local iconPanelShouldY = 7

local mainBoxColor = Vector(20, 20, 20)
local mainBoxColorShould = Vector(20, 20, 20)

buildEnabled = buildEnabled or false
local menuOpen = false
local menuShould = false
local onCooldown = false
local cooldownExpiry
local isBlocked = false
local blockExpiry

firstGo = firstGo or {false, nil, nil}

local materials = {}
local function preRenderMaterial(name, store)
    if materials[store] == nil then
        materials[store] = Material(name .. ".png")
    end
end

preRenderMaterial('icon16/wrench', 'wrench')
preRenderMaterial('icon16/bomb', 'bomb')
preRenderMaterial('rl_build_hud_mats/pvp_icon', 'pvp')
preRenderMaterial('rl_build_hud_mats/build_icon', 'build')

local function betterRound(num)
    //if num < 1 and num > -1 then return 0 else return num end
    return math.Round(num, 3)
end

hook.Add("OnPlayerChat", "rbuild_testcmd", function(ply, msg)
    if msg == "/test" then
        for k, v in pairs(player.GetAll()) do
            //print(v:Nick())
            //print(v:GetNWBool("rbuild_enabled", nil))
        end
    end
end)

local function buildText()
    return (buildEnabled and "BUILD" or "PVP")
end

local function createAlert(text, removeIn)
    local textW, textH = draw.SimpleText(text, "HUDSmallNumberDisplay", 0, 0, Color(0, 0, 0, 0))
    alertWidthShould = textW + 30

    removeIn = removeIn or 3

    local watchForRemove = false

    local alert = vgui.Create("DFrame")
    alert:SetSize(1, 30)
    alert:Center()
    alert:SetTitle("")
    alert:ShowCloseButton(false)
    alert:SetDraggable(false)
    alert.Paint = function(self, w, h)
        alertWidth = Lerp(FrameTime() * 10, alertWidth, alertWidthShould)
        alert:SetSize(alertWidth, 30)
        alert:Center()

        if alertWidth == 0 then print("removing"); alert:Remove() end

        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30))
        draw.SimpleText(text, "HUDSmallNumberDisplay", w / 2, h / 2 - 1, Color(255, 255, 255), 1, 1)
    end

    if timer.Exists("rubild_alertremove") then timer.Start("rbuild_alertremove") else
        timer.Create("rbuild_alertremove", removeIn, 1, function()
            alertWidthShould = 0
            watchForRemove = true
        end)
    end
end

// STARTTTTTTTTTTTTTTT

rbuildPanel = rbuildPanel or nil
hook.Add("buttonbarMasterReady", "rbuild_context", function()
    rbuildPanel = g_bbMasterPanel:Add("rlBarButton")
    rbuildPanel:Setup("PVP MODE", "rl_build_hud_mats/pvp_icon.png", "rl_build_hud_mats/build_icon.png")
    rbuildPanel.CallbackFunc = function(self)
        net.Start("rbuild_change")
        net.SendToServer()
        //self:SwitchToColor(math.Rand(0, 255), math.Rand(0, 255), math.Rand(0, 255))
    end
    hook.Call("buttonbarBuildLoaded")
end)

local function blockText(time)
    rbuildPanel:UpdateText(buildText() .. " MODE <color=220,0,0>BLOCKED FOR " .. time .. " SECONDS</color>")
end

local function cooldownText(time)
    rbuildPanel:UpdateText(buildText() .. " MODE <color=66,134,244>SWITCHING IN " .. time .. " SECONDS</color>")
end

local function resetText()
    rbuildPanel:UpdateText(buildText() .. " MODE")
end

// ENDDDDDDDDDDDDDDDDD

net.Receive("rbuild_block", function(len)
    local info = net.ReadTable()
    rbuildPanel:ForceOpen(true)
    rbuildPanel:SwitchToColor(220, 0, 0)
    rbuildPanel:UpdateText()
    blockText(info.time)
    timer.Remove("rbuild_cooldowntext")
    timer.Remove("rbuild_cooldown")
    timer.Create("rbuild_blocktext", 1, info.time - 1, function()
        blockText(timer.RepsLeft("rbuild_blocktext") + 1)
    end)
    timer.Simple(info.time, function()
        rbuildPanel:ForceOpen(false)
        rbuildPanel:SwitchToColor(20, 20, 20)
        resetText()
    end)
end)

net.Receive("rbuild_cancel", function(len)
    timer.Remove("rbuild_cooldown")
    //rbuildPanel:ForceOpen(false)
    //rbuildPanel:SwitchToColor(20, 20, 20)
    //resetText()

    createAlert("YOU MOVED, THEREFORE YOUR MODE SWITCH WAS CANCELLED", 4)
end)

net.Receive("rbuild_change", function(len)
    local info = net.ReadTable()
    rbuildPanel:ForceOpen(true)
    rbuildPanel:SwitchToColor(66, 134, 244)
    cooldownText(info.cooldown)
    timer.Create("rbuild_cooldowntext", 1, info.cooldown - 1, function()
        cooldownText(timer.RepsLeft("rbuild_cooldowntext") + 1)
    end)
    timer.Create("rbuild_cooldown", info.cooldown, 1, function()
        rbuildPanel:SwitchToColor(20, 20, 20)
        buildEnabled = info.state
        rbuildPanel:SetIcon(!buildEnabled)
        resetText()
        timer.Simple(0.5, function()
            rbuildPanel:ForceOpen(false)
        end)
    end)
end)

net.Receive("BuildmodeForcechanged", function()

    buildEnabled = net.ReadBool()
    rbuildPanel:SetIcon(!buildEnabled)
    resetText()
    if (buildEnabled) then 
        chat.AddText(Color(255,255,255), "You were forced into buildmode by an admin.")
    else 
        chat.AddText(Color(255,255,255), "You were forced out of buildmode by an admin.")
    end 

end)