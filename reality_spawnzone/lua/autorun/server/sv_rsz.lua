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

local tConfigBoiler = {
    ranks = { "owner", "ownerassistant", "superadmin", "admin" },
    delay = 3,
    transparent = true,
    removevehicles = true,
    removenpcs = false,
    removeprops = true,
    propwhitelist = { "76561198099827853" },
    addcommand = "!rsz_add",
    delcommand = "!rsz_remove"
}

util.AddNetworkString("rsz_sendzones")
util.AddNetworkString("rsz_newzone")
util.AddNetworkString("rsz_removezone")
util.AddNetworkString("rsz_resetprotection")
local sFileName = "rsz/" .. game.GetMap() .. ".txt"

// Create meta functions for ease of use
local meta = FindMetaTable("Player")
function meta:rszIsProtected()
    return self.rsz_isProtected
end
function meta:rszWasProtected()
    return self.rsz_wasProtected
end
function meta:rszSetProtected(bSet)
	if IsValid(self) then 
		self.rsz_isProtected = tobool(bSet)
		if bSet == false then
			self.rsz_wasProtected = true
			local c = self:GetColor()
			self:SetRenderMode(RENDERMODE_NORMAL)
			self:SetColor(Color(c.r, c.g, c.b, 255))
		end
	end
end

// Load current map's safezones into table
local function getSafezones()
    if not file.IsDir("rsz", "DATA") then file.CreateDir("rsz", "DATA") end
    if not file.Exists(sFileName, "DATA") then file.Write(sFileName, "{}") end
    return util.JSONToTable(file.Read(sFileName, "DATA"))
end
rsz.safezones = getSafezones()

// Load config from garrysmod/data/rsz/config.txt
local function getConfig()
    if not file.Exists("rsz/config.txt", "DATA") then file.Write("rsz/config.txt", util.TableToJSON(tConfigBoiler)) end
    local tab = util.JSONToTable(file.Read("rsz/config.txt"))
    tab.ranks = rsz.noKVToQA(tab.ranks)
    tab.propwhitelist = rsz.noKVToQA(tab.propwhitelist)
    return tab
end
rsz.config = getConfig()

// Save zones to file
local function saveSafezones()
    file.Write(sFileName, util.TableToJSON(rsz.safezones, true))
end

// Create function to check for ents in spawnzones (loop through all sz's -> loop through all players)
local function checkInZones()
    for _, x in pairs(rsz.safezones) do
        local tEntsIn = ents.FindInBox(x[1], x[2])
        for k, v in pairs(tEntsIn) do
            if v:IsPlayer() and v:IsValid() and IsValid(v) and v.rsz_fully_connected != nil then
                if not v:rszWasProtected() then
                    v:rszSetProtected(true)

                    // If transparency is enabled, make player transparent to other users
                    if rsz.config.transparent then
                        local c = v:GetColor()
                        v:SetRenderMode(RENDERMODE_TRANSALPHA)
                        v:SetColor(Color(c.r, c.g, c.b, 100))
                    end

                    // Setup timer for removing spawn protection
                    local sTimerId = "rsz_prottimer_" .. v:UniqueID()
                    if not timer.Exists(sTimerId) then
                        timer.Create(sTimerId, rsz.config.delay, 1, function() v:rszSetProtected(false) end)
                    else
                        timer.Start(sTimerId)
                    end
                end
            end

            // If removing props is enabled, remove props in spawnzones
            if rsz.config.removeprops and ((v:GetClass() == "prop_physics" and !v.jailWall) or (string.find(v:GetClass(), "wire") and v:GetClass() != "gmod_wire_hologram")) then
                if v:CPPIGetOwner() != nil then
                    // If player's ID is not in whitelist, remove the prop
                    if rsz.config.propwhitelist[v:CPPIGetOwner():SteamID64()] != true then v:Remove() end
                else
                    v:Remove()
                end
            end

            // Other checks for ents in spawnzones
            if rsz.config.removevehicles and v:IsVehicle() then v:Remove() end
            if rsz.config.removenpcs and (v:IsNPC() or v.Type == "nextbot") then v:Remove() end
        end
    end
end

// Reset rszWasProtected on respawn
hook.Add("PlayerDeath", "rsz_resetprotection", function(ply)
	//print(ply:Nick() .. " reset")
    ply.rsz_wasProtected = false
    net.Start("rsz_resetprotection")
    net.Send(ply)
end)

// Send all safezones to newly connected players
hook.Add("PlayerInitialSpawn", "rsz_sendzones", function(ply)
	ply.rsz_fully_connected = true 
    net.Start("rsz_sendzones")
        net.WriteTable({ rsz.config, rsz.safezones })
    net.Send(ply)
end)

// Command to force all clients (and server) into updating the spawnzones
local function forceReload()
    rsz.safezones = getSafezones()
    rsz.config = getConfig()
    timer.Simple(0, function() // Wait to queue for next frame to avoid sending before changes take place
        net.Start("rsz_sendzones")
            net.WriteTable({ rsz.config, rsz.safezones })
        net.Broadcast()
    end)
end
concommand.Add("rsz_forcereload", function(ply)
	if IsValid(ply) then 
		if rsz.config.ranks[ply:GetUserGroup()] == true then
			forceReload()
		end
	else 
		forceReload()
	end
end)

// Don't display the command when used
/*hook.Add("PlayerSay", "rsz_hidecommand", function(ply, text)
    if string.Trim(text) == rsz.command then return "" end
end)*/

// Stop players from taking damage while protected
hook.Add("EntityTakeDamage", "rsz_blockdamage", function(ent, dmg)
    if !ent:IsValid() or !ent:IsPlayer() then return end // If invalid, cancel
    if ent:rszIsProtected() then return true end  // If the person taking damage is spawn protected, negate

    local attacker = dmg:GetAttacker()
    if attacker:IsValid() and attacker:IsPlayer() and attacker:rszIsProtected() then return true end  // If the attacker is spawn protected, negate
end)

// Add new zones when an authorized user creates one
net.Receive("rsz_newzone", function(_, ply)
    if rsz.config.ranks[ply:GetUserGroup()] == true then
        local tPoints = net.ReadTable()
        if #tPoints == 2 then
            table.insert(rsz.safezones, tPoints)
            saveSafezones()
            forceReload()
            ply:ChatPrint("[RSZ] New spawnzone is confirmed serverside.")
        else
            ply:ChatPrint("[RSZ] Edge case #2, please report to developer.")
        end
    else
        ply:ChatPrint("[RSZ] You do not have permission to perform this action.")
    end
end)

// Remove zone when authorized user executes command
net.Receive("rsz_removezone", function(_, ply)
    local iZoneToRemove = net.ReadUInt(8)
    if rsz.config.ranks[ply:GetUserGroup()] == true and iZoneToRemove != nil then
        table.remove(rsz.safezones, iZoneToRemove)
        saveSafezones()
        forceReload()
        ply:ChatPrint("[RSZ] Spawnzone #" .. iZoneToRemove .. " has been removed, spawnzones have been updated.")
    else
        ply:ChatPrint("[RSZ] You do not have permission to perform this action.")
    end
end)

// Start looping timer to check safezones for entities
timer.Create("rsz_checkforents", 0.05, 0, checkInZones)
