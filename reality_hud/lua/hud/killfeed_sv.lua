-- i'm here!
util.AddNetworkString("rhud_senddeathkillfeed")
hook.Add("PlayerDeath", "rhud_killfeedondeath", function(victim, inflictor, attacker)
    local info = {}
    info.victim = victim
    info.inflictor = inflictor
    info.attacker = attacker

    net.Start("rhud_senddeathkillfeed")
    net.WriteTable(info)
    net.Broadcast()
end)
