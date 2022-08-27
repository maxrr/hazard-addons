RLVC.currentChannel = RLVC.currentChannel or "global"

RLVC.barPanel = RLVC.barPanel or nil

hook.Add("buttonbarBuildLoaded", "rlvc_context", function()
    RLVC.barPanel = g_bbMasterPanel:Add("rlBarButton")
    RLVC.barPanel:Setup(string.upper(RLVC.currentChannel) .. " VOICE CHAT", "rl_voicechannels_mats/global.png", "rl_voicechannels_mats/prox.png")
    RLVC.barPanel.CallbackFunc = function(self)
        net.Start("rlvc_setchannel")
        net.SendToServer()
    end
end)

net.Receive("rlvc_setchannel", function(len)
    local plyInQuestion = net.ReadEntity()
    local channel = net.ReadBit()
    local sChannelStr
    if channel == 0 then sChannelStr = "global"
    elseif channel == 1 then sChannelStr = "proximity"
    else ErrorNoHalt("RLVC channel bit invalid, expecting 1 or 0, got ", channel) end

    if RLVC.establishedChannels[sChannelStr] == true then
        plyInQuestion.rlvc_channel = sChannelStr

        if plyInQuestion == LocalPlayer() then
			chat.AddText("You have switched your voice channel to ", sChannelStr)
            RLVC.currentChannel = sChannelStr

			if RLVC.barPanel then
				RLVC.barPanel:SetIcon(!tobool(channel))
				RLVC.barPanel:UpdateText(string.upper(sChannelStr) .. " VOICE CHAT")
			else
				ErrorNoHalt("RLVC.barPanel does not exist")
			end
        end
    end
end)

local bDumpReceived = false
local bFullyLoaded = false
local tDumpedInfo

local function initDumpedInfo()
	if tDumpedInfo != nil and bDumpReceived and bFullyLoaded then
		for k, v in pairs(tDumpedInfo) do
			player.GetBySteamID64(v[1]).rlvc_channel = v[2]
		end
	end
end

net.Receive("rlvc_dumpToNewlyConnected", function(_)
    tDumpedInfo = net.ReadTable()
	bDumpReceived = true
	initDumpedInfo()
end)

hook.Add("InitPostEntity", "rlvc_fullyloaded", function()
	bFullyLoaded = true
	initDumpedInfo()
end)

net.Receive("rlvc_newlyConnected", function(_)
    local ply = net.ReadEntity()
    ply.rlvc_channel = RLVC.defaultChannel
end)
