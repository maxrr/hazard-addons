
hook.Add("Initialize", "rlvc_remove_default", function()
	hook.Remove("InitPostEntity", "CreateVoiceVGUI")
end)

/*----- tags -------
1 - friend
2 - blocked
3 - staff
4 - none
------------------*/

local function drawCircle(x, y, r)
	local circle = {}

	for i = 1, 360 do
		circle[i] = {}
		circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
		circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
	end

	surface.DrawPoly(circle)
end

RLVC = RLVC or {}
RLVC.TalkingPly = {}
RLVC.VoiceContext = RLVC.VoiceContext or {}

RLVC.VoiceFirstGo = RLVC.VoiceFirstGo or {}
if RLVC.VoiceFirstGo[1] == nil then RLVC.VoiceFirstGo[1] = "true" end

RLVC.VoiceConstants = {}
RLVC.VoiceConstants[1] = 240                                   -- main width
RLVC.VoiceConstants[2] = ScrW() - RLVC.VoiceConstants[1] - 10  -- main width offset (active)
RLVC.VoiceConstants[3] = ScrW() + 10                           -- main width offset (inactive)
RLVC.VoiceConstants[4] = ScrW() + 10                           -- main width offset (current)
RLVC.VoiceConstants[5] = 040                                   -- main height offset
RLVC.VoiceConstants[6] = 300                                   -- main height
RLVC.VoiceConstants[7] = 10                                   -- fade speed

local function drawVoiceChat()
    local constants = RLVC.VoiceConstants
    local frame = vgui.Create("DFrame")
    frame:SetSize(constants[1], constants[6])
    frame:SetPos(constants[4], constants[5])
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        if RLVC.ContextOpen == true then
            frame:SetPos()
        end
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20))
    end
    table.insert(RLVC.VoiceContext, frame)
end

hook.Add("HUDPaint", "rlvc_voiceChatIndicator", function()
	for k, v in pairs(RLVC.TalkingPly) do

		if v[5] == nil then
			local frame = vgui.Create("DFrame")
			frame:SetSize(36 + v[4][2] + 12, 32)
			frame:SetPos(ScrW() - frame:GetWide() - 10, ScrH() - (((k - 1) * 36) + 166))
			frame:SetTitle("")
			frame:ShowCloseButton(false)
			frame:SetAlpha(0)
			frame:TDLib()
				:ClearPaint()
				//:FadeIn(RLVC.VoiceConstants[7], 255)
				:On("Paint", function(s, w, h)
					v[10] = Lerp(RealFrameTime() * RLVC.VoiceConstants[7], v[10], v[11])
					s:SetAlpha(v[10])
					if v[10] <= 5 then
						s:Remove()
						table.remove(RLVC.TalkingPly, k)
					end


					local bgCol = HSVToColor(v[12], 1, v[1]:VoiceVolume())

					draw.RoundedBoxEx(8, 0, 0, w - 32, h, bgCol, true, false, true, false)
					//draw.RoundedBoxEx(8, w - 36, 0, 36, h, Color(255, 255, 255), false, true, false, true)
					draw.SimpleText(v[4][1], "RLVC_TalkingIndicator", w - 39, h / 2, Color(255, 255, 255), 2, 1)
				end)

			local avNest = TDLib("DPanel", frame)
			avNest:SetSize(32, 32)
			avNest:AlignRight(v[7])
			avNest:AlignTop(0)
			avNest:ClearPaint()
			avNest:On("Paint", function(s, w, h)
				v[7] = Lerp(FrameTime() * 10, v[7], v[8])
				if (math.abs(v[7] - v[8]) <= 0.5) then
					v[7] = v[8]
				end
				s:AlignRight(v[7])
			end)

			local av = vgui.Create("DPanel", avNest)
			av:SetSize(32, 32)
			av:Dock(FILL)
			av:TDLib()
				:AvatarMask(function(s, w, h)
					local curPosX, curPosY = frame:GetPos()
					local relativeX, relativeY = s:ScreenToLocal(curPosX + frame:GetWide() - 32, curPosY)
					local round = 6
					surface.DrawRect(relativeX, relativeY, 32 - round, 32)
					surface.DrawRect(relativeX, round, 32, 32 - round * 2)
					drawCircle(relativeX + 32 - round, relativeY + round, round)
					drawCircle(relativeX + 32 - round, relativeY + 32 - round, round)
				end)
				:SetSteamID(v[2], 32)
			av:On("Paint", function(s)
					s:SetAlpha(frame:GetAlpha() ^ 2)
			end)

			RLVC.TalkingPly[k][5] = frame
		end
	end
end)

if RLVC.VoiceFirstGo[1] == "false" then
    drawVoiceChat()
else
    RLVC.VoiceFirstGo[1] = "false"
end

hook.Add("InitPostEntity", "rlvc_debugInit", function()
    timer.Simple(4, function()
        drawVoiceChat()
        RLVC.VoiceFirstGo[1] = "false"
    end)
end)

hook.Remove("PlayerStartVoice", "rlvc_voiceStart")
hook.Add("PlayerStartVoice", "rlvc_voiceStart", function(ply)
	for k, v in pairs(RLVC.TalkingPly) do
		if v[2] == ply:SteamID64() then
			v[11] = 255
			return
		end
	end

    local appliedTag = 4
    if ply:GetFriendStatus() == "friend" then appliedTag = 1
    elseif ply:GetFriendStatus() == "blocked" then appliedTag = 2
    elseif RLVC.staffRanks[ply:GetUserGroup()] == true then appliedTag = 3
    end

	local nick = string.upper(ply:Nick())
	surface.SetFont("RLVC_TalkingIndicator")
	local tw, th = surface.GetTextSize(nick)

    table.insert(RLVC.TalkingPly, {
		ply, 				-- 1 player
		ply:SteamID64(), 	-- 2 player id

		appliedTag, 		-- 3 tag (unused yet)
		{nick, tw}, 		-- 4 name and tw
		nil, 				-- 5 frame (set in context)

		false, 				-- 6 should fade out
		80, 				-- 7 avatar current (aligned from right)
		0,					-- 8 avatar should (aligned from right)
		true,               -- 9 should fade in

		0,                  -- 10 opacity current
		255,                -- 11 opacity should

		ColorToHSV(team.GetColor(ply:Team())), -- 12 team color hue
	})
end)

hook.Remove("PlayerEndVoice", "rlvc_voiceEnd")
hook.Add("PlayerEndVoice", "rlvc_voiceEnd", function(ply)
    for k, v in pairs(RLVC.TalkingPly) do
        if v[2] == ply:SteamID64() then
            if v[5] != nil then
				v[11] = 0
			else
				table.remove(RLVC.TalkingPly, k)
			end
        end
    end
end)
