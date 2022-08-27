util.AddNetworkString("rbuild_change")
util.AddNetworkString("rbuild_cancel")
util.AddNetworkString("rbuild_block")

local cooldown = 2
local block = 2

local meta = FindMetaTable("Player")
function meta:makeCooldown()
    self:SetNWBool("rbuild_cooldown", true)
    timer.Create("rbuild_makecooldown" .. self:SteamID64(), cooldown, 1, function()
        self:SetNWBool("rbuild_cooldown", false)
    end)
end
function meta:isCooldown()
    return self:GetNWBool("rbuild_cooldown", false)
end
function meta:stopCooldown()
    self:SetNWBool("rbuild_cooldown", false)
    timer.Remove("rbuild_cooldown" .. self:SteamID64())
    timer.Remove("rbuild_makecooldown" .. self:SteamID64())

    net.Start("rbuild_cancel")
    net.Send(self)
end
function meta:isBuild()
    return self:GetNWBool("rbuild_enabled", false)
end
function meta:toggleBuild()
	local plyIsBuild = self:GetNWBool("rbuild_enabled", false)
    self:SetNWBool("rbuild_enabled", !plyIsBuild)
	if plyIsBuild == true then self:SetMoveType(MOVETYPE_WALK) end
    hook.Run("RBuildModeChange", self, !plyIsBuild)
    return !plyIsBuild
end
function meta:setBuild(to)
    self:SetNWBool("rbuild_enabled", to)
    hook.Run("RBuildModeChange", self, !plyIsBuild)
end
function meta:isBlocked()
    return self:GetNWBool("rbuild_block", false)
end
function meta:blockSwitching(time)
    self:SetNWBool("rbuild_block", true)
    net.Start("rbuild_block")
    net.WriteTable({ ['time'] = time })
    net.Send(self)
    timer.Simple(time, function()
        self:SetNWBool("rbuild_block", false)
    end)
end

/*hook.Add("Think", "rbuild_showbuildplayerstransparent", function()
    for k, v in pairs(player.GetAll()) do
        if false then
            local c = v:GetColor()
            v:SetRenderMode(RENDERMODE_TRANSALPHA)
            v:SetColor(Color(c.r, c.g, c.b, 100))
        else
            local c = v:GetColor()
            v:SetRenderMode(RENDERMODE_TRANSALPHA)
            v:SetColor(Color(c.r, c.g, c.b, 255))
        end
    end
end)*/

//hook.Remove("Think", "rbuild_showbuildplayerstransparent")

hook.Add("PlayerShouldTakeDamage", "rbuild_blockdamage", function(ply, attacker)
    if attacker:IsPlayer() then
        if attacker:isBuild() then
            return false
        end
    end
    if ply:isBuild() then
        return false
    end
end)

local function changeBuildState(ply)
	if !ply:isCooldown() and !ply:isBlocked() then
        ply:makeCooldown()
        net.Start("rbuild_change")
        net.WriteTable({ ['cooldown'] = cooldown, ['state'] = !ply:isBuild() })
        net.Send(ply)
        timer.Create("rbuild_cooldown" .. ply:SteamID64(), cooldown, 1, function()
            local newBuildState = ply:toggleBuild()
        end)
    end
end

net.Receive("rbuild_change", function(_, ply)
    changeBuildState(ply)
end)

hook.Add("PlayerNoClip", "rbuild_letbuildnoclip", function(ply, state)
    if state == false then return true end
    if ply:isBuild() and not ply:isCooldown() then return true end
end)

local hasPrinted = false

hook.Add("Move", "rbuild_checkmovement", function(ply, mv)
    local isCooldown = ply:isCooldown()
    if isCooldown then
        if mv:GetVelocity() != Vector(0, 0, 0) then
            ply:stopCooldown()
            ply:blockSwitching(block)
        end
    end
end)

hook.Add("PlayerSay", "rbuild_ryanisadouchebag", function(ply, msg)
    /*if ply:Nick() == "Reality" then
        if msg == "f" then player.GetAll()[2]:Freeze(true) end
        if msg == "uf" then player.GetAll()[2]:Freeze(false) end
    end*/
	if string.lower(msg) == "!build" or string.lower(msg) == "!pvp" then
		changeBuildState(ply)
		return ""
	end
end)

//resource.AddFile("materials/rl_build_hud_mats/pvp_icon.png")
//resource.AddFile("materials/rl_build_hud_mats/build_icon.png")
