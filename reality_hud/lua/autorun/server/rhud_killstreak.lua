rhud_ks = rhud_ks or {}

local kmsg_adj = {
	"ludicrous",
	"nonsensical",
	"thrilling",
	"astonishing",
	"breathtaking",
	"far out",
	"groovy",
	"bean-a-licious",
	"fabulous",
	"amazing",
	"incredible",
	"monstrous",
	"neat",
	"sensational",
	"spine-tingling",
	"heart-throbbing",
	"porcupine-tickling",
	"bamboozling",
    "stormy",
    "kablamo",
}

local kmsg_die = {
	"oh, no",
	"horrible",
	"bummer",
	"geez",
	"ugh",
	"ouch",
	"that sucks",
    "uh oh spaghet",
}

local function kmsg(ply, killer, death)
    local kills = rhud_ks[ply:SteamID64()]
	if kills == nil then return end
    if ((death == false and (kills % 5 == 0 or kills >= 25)) or ((death == nil or death == true) and kills >= 5)) and kills != 0 then
        local msg
        if death == true or death == nil then msg = kmsg_die[math.random(#kmsg_die)] else msg = kmsg_adj[math.random(#kmsg_adj)] end

        local info = {}
        info.ply = ply
        info.killer = killer
        info.death = death
        info.kills = kills
        info.msg = msg

        net.Start("rhud_ks-exclaim")
        net.WriteTable(info)
        net.Broadcast()
    end
end

net.Receive("rhud_ks-init", function(len, ply)
    -- sv
    rhud_ks[ply:SteamID64()] = 0

    -- net
    net.Start("rhud_ks-init")
    net.WriteTable(rhud_ks)
    net.Send(ply)

    net.Start("rhud_ks-new")
    net.WriteEntity(ply)
    net.Broadcast()
end)

local function rhud_addkill(death, killer)
    -- check
	if death == killer then
        local info = {}
        info.death = death
        info.killer = nil

        net.Start("rhud_ks-add")
        net.WriteTable(info)
        net.Broadcast()

        kmsg(death, nil, nil)

        local id = death:SteamID64()
        rhud_ks[id] = 0

        return
    end
	if !IsValid(death) then return end
    if death == nil or killer == nil then return end
    if !death:IsPlayer() then return end
    if !killer:IsPlayer() then
        local info = {}
        info.death = death
        info.killer = nil

        net.Start("rhud_ks-add")
        net.WriteTable(info)
        net.Broadcast()

        kmsg(death, nil, nil)

        local id = death:SteamID64()
        rhud_ks[id] = 0

        return
    end

    -- prepare table
    local info = {}
    info.death = death
    info.killer = killer

    -- net
	net.Start("rhud_ks-add")
    net.WriteTable(info)
    net.Broadcast()

    -- func
    kmsg(death, killer, true)

    -- sv update
    id = death:SteamID64()
    rhud_ks[id] = 0

    id = killer:SteamID64()
    if rhud_ks[id] == nil then rhud_ks[id] = 0 end
    rhud_ks[id] = rhud_ks[id] + 1

    -- func
    kmsg(killer, nil, false)
end

hook.Add("PlayerDeath", "rhud_addkill", function(death, weapon, killer)
    rhud_addkill(death, killer)
	if death:Frags() < 0 then death:SetFrags(0) end 
end)

hook.Add("PlayerDisconnected", "rhud_playerdc", function(ply)
    -- sv
	local s64 = ply:SteamID64()
    rhud_ks[ply:SteamID64()] = nil

    -- net
    net.Start("rhud_ks-dc")
    net.WriteString(s64)
    net.Broadcast()
end)

concommand.Add("rhud_ks-reset", function()
    rhud_ks = {}
    for k, v in pairs(player.GetAll()) do
        rhud_ks[v:SteamID64()] = 0
    end

    net.Start("rhud_ks-reset")
    net.WriteTable(rhud_ks)
    net.Broadcast()
end)
