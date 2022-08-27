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

local tPointBuffer = {}
local bIsEditing = false
local bProtected = false
local bLeftZone = false
local iZoneInside = 0
local sDescText = [[When in a safezone, you cannot
deal or take any damage.]]

if GetConVar("rsz_showzones") == nil then
    CreateClientConVar("rsz_showzones", "0")
end
local bShowZones = GetConVar("rsz_showzones"):GetBool()
local VectorRound = rsz.vectorRound

// Load received table into RSZ global
net.Receive("rsz_sendzones", function()
    local tNetTab = net.ReadTable()
    rsz.config = tNetTab[1]
    rsz.safezones = tNetTab[2]
    rsz.safezoneFaces = {}
    for k, v in pairs(rsz.safezones) do
        local tFaces = {
            //{ VectorRound((v[1].x + v[2].x) / 2, (v[1].y + v[2].y) / 2, v[1].z), Angle(0, 0, 0), "TOP" },
            //{ VectorRound(v[1].x, (v[1].y + v[2].y) / 2, (v[1].z + v[2].z) / 2), Angle(-90, 0, 0), "LEFT" },
            //{ VectorRound((v[1].x + v[2].x) / 2, v[1].y, (v[1].z + v[2].z) / 2), Angle(-90, 90, 0), "FRONT" },

            { VectorRound((v[1].x + v[2].x) / 2, (v[1].y + v[2].y) / 2, math.min(v[2].z, v[1].z)), Angle(180, 0, 0), "BOTTOM" },
            //{ VectorRound(v[2].x, (v[1].y + v[2].y) / 2, (v[1].z + v[2].z) / 2), Angle(90, 0, 0), "RIGHT" },
            //{ VectorRound((v[1].x + v[2].x) / 2, v[2].y, (v[1].z + v[2].z) / 2), Angle(90, 90, 0), "BACK" },
        }
        rsz.safezoneFaces[k] = tFaces
    end
end)

// Utilities to easily create a new spawnpoint
hook.Add("OnPlayerChat", "rsz_newzonechat", function(ply, text)
    text = string.Trim(text)
    if not ply:IsValid() then return end
    if rsz.config.ranks[ply:GetUserGroup()] == true then
        if text == rsz.config.addcommand then
            if ply == LocalPlayer() then
                if bIsEditing then
                    bIsEditing = false
                    tPointBuffer = {}
                    ply:ChatPrint("[RSZ] Cancelled placing a spawnzone. No changes have been made.")
                else
                    bIsEditing = true
                    tPointBuffer = {}
                    ply:ChatPrint("[RSZ] Started placing a spawnzone. Left click to place first point, right click to cancel.")
                end
            end
            return true // Suppress message
        elseif string.sub(text, 1, string.len(rsz.config.delcommand)) == rsz.config.delcommand then
            if ply == LocalPlayer() then
                local iZoneToRemove = tonumber(string.sub(text, string.len(rsz.config.delcommand) + 1, string.len(text)))
                if iZoneToRemove != nil then
                    net.Start("rsz_removezone")
                        net.WriteUInt(iZoneToRemove, 8)
                    net.SendToServer()
                    ply:ChatPrint("[RSZ] Sent request to server to remove spawnzone #" .. iZoneToRemove .. ".")
                else
                    ply:ChatPrint("[RSZ] You must supply a zone ID, find with \"rsz_showzones (0/1)\" in console.")
                end
            end
            return true
        end
    end
end) //

// Check +attack (m1) and +attack2 (m2) inputs to enable new spawnzone creation
hook.Add("PlayerBindPress", "rsz_checkinputs", function(ply, stroke)
    if bIsEditing then
        if stroke == "+attack" then // Left mouse
            local vTrace = ply:GetEyeTrace().HitPos
            if #tPointBuffer == 0 then
                table.insert(tPointBuffer, vTrace)
                ply:ChatPrint("[RSZ] Inserted first point. Left click to place second point, right click to cancel.")
            elseif #tPointBuffer == 1 then
                table.insert(tPointBuffer, vTrace)
                ply:ChatPrint("[RSZ] Inserted second point. Left click to confirm new spawnzone, right click to cancel.")
            elseif #tPointBuffer == 2 then
                local bFirstLower = (tPointBuffer[1].z < tPointBuffer[2].z)
                if bFirstLower then tPointBuffer[1].z = tPointBuffer[1].z - 2 else tPointBuffer[2].z = tPointBuffer[2].z - 2 end
                net.Start("rsz_newzone")
                    net.WriteTable(tPointBuffer)
                net.SendToServer()

                bIsEditing = false
                tPointBuffer = {}
                ply:ChatPrint("[RSZ] Confirmed new spawnzone.")
            else
                bIsEditing = false
                tPointBuffer = {}
                ply:ChatPrint("[RSZ] Edge case #1, please report to developer.")
            end
        elseif stroke == "+attack2" then // Right mouse
            bIsEditing = false
            tPointBuffer = {}
            ply:ChatPrint("[RSZ] Cancelled creation of spawnzone.")
        end
    end
end)

// Check if player is in any safezone
local function checkInZones()
    if not LocalPlayer():IsValid() then return end
    local bInZone = false
    for l, x in pairs(rsz.safezones) do
        if bInZone == false and bLeftZone == false then
            if LocalPlayer():GetPos():WithinAABox(x[1], x[2]) then
                iZoneInside = l
                bInZone = true
                if timer.Exists("rsz_leavetimer") then timer.Destroy("rsz_leavetimer") end
                bProtected = true
            else
                if not timer.Exists("rsz_leavetimer") and bProtected then
                    timer.Create("rsz_leavetimer", rsz.config.delay, 1, function() bProtected = false; iZoneInside = 0; bLeftZone = true end)
                end
            end
        end
    end
end
timer.Create("rsz_checkinzone", 0.05, 0, checkInZones)

// Reset bLeftZone on respawn
net.Receive("rsz_resetprotection", function()
    bLeftZone = false
end)

// Update bShowZones every second
timer.Create("rsz_showzoneupdate", 1, 0, function()
    bShowZones = GetConVar("rsz_showzones"):GetBool()
end)

// Draw indicators on the screen
hook.Add("HUDPaint", "rsz_drawindicator", function()
    local w, h = ScrW(), ScrH()
    local pnlW, pnlH = 250, 60
    local cThemeCol = Color(30, 30, 30)
    local cTimerCol = Color(48, 179, 255)
    if bProtected then
        local iTimeRemaining = timer.TimeLeft("rsz_leavetimer") or rsz.config.delay
        draw.RoundedBoxEx(8, w/2-pnlW/2, 4, pnlW, pnlH, cThemeCol, false, false, true, true)
        draw.RoundedBoxEx(2, w/2-pnlW/2, 0, pnlW * (iTimeRemaining/rsz.config.delay), 4, cTimerCol, true, true, false, false)
        draw.RoundedBox(0, w/2-pnlW/2, 4, pnlW, 20, Color(60, 60, 60))
        draw.SimpleText("YOU ARE IN A SAFEZONE", "DermaDefaultBold", w/2, 14, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.DrawText(sDescText, "DermaDefault", w/2, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    if bShowZones then
        local tMidp = {}
        cam.Start3D()
            for k, v in pairs(rsz.safezones) do
                local vMidp = (v[1] + v[2]) / 2
                table.insert(tMidp, vMidp:ToScreen())
            end
        cam.End3D()
        for k, v in pairs(tMidp) do
            if v.visible then
                local x, y = v.x, v.y
                local s = 40
                draw.RoundedBox(8, x-s/2, y-s/2, s, s, Color(30, 30, 30, 200))
                draw.SimpleText(k, "DermaDefaultBold", x, y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end)

// Draw zones preview (only if in zone)
hook.Add("PostDrawOpaqueRenderables", "rzs_drawzones", function()
    if iZoneInside != 0 then
        for k, v in pairs(rsz.safezones) do
            if iZoneInside == k then
                local tFaces = rsz.safezoneFaces[k]
                local iHeight = math.abs(v[1].z - v[2].z)
                local iDepth = math.abs(v[1].y - v[2].y)
                local iWidth = math.abs(v[1].x - v[2].x)
                local iBorder = 4
                local iBorderColor = Color(40, 81, 145)
                local iWallColor = Color(40, 81, 145, 10)
                for l, x in pairs(tFaces) do
                    local w, h
                    if x[3] == "TOP" or x[3] == "BOTTOM" then w = iWidth + 1; h = iDepth + 1 end
                    if x[3] == "LEFT" or x[3] == "RIGHT" then w = iHeight + 1; h = iDepth + 1 end
                    if x[3] == "FRONT" or x[3] == "BACK" then w = iHeight + 1; h = iWidth + 1 end
                    cam.IgnoreZ(true)
                    cam.Start3D2D(x[1] + Vector(0, 0, 2), x[2], 1)
                        draw.RoundedBox(0, -w/2, -h/2, w, h, iWallColor)
                        if x[3] == "BOTTOM" or x[3] == "TOP" then
                            draw.RoundedBox(0, -w/2, -h/2, iBorder, h, iBorderColor)
                            draw.RoundedBox(0, -w/2, -h/2, w, iBorder, iBorderColor)
                            draw.RoundedBox(0, w/2-iBorder, -h/2, iBorder, h, iBorderColor)
                            draw.RoundedBox(0, -w/2, h/2-iBorder, w, iBorder, iBorderColor)
                        end
                    cam.End3D2D()
                    cam.IgnoreZ(false)
                end
            end
        end
    end
end)
