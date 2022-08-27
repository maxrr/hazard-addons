rhud_kf = {
    --{markup.Parse("<font=HUDSmallNumberDisplay>ayy lmao testing</font>"), "test", false, 0, false, 1},
    --{markup.Parse("<font=HUDSmallNumberDisplay>ayy lmao testing #2</font>"), "ayy lmao", false, 0, false, 10},
    --{markup.Parse("<font=HUDSmallNumberDisplay>ayy lmao testing #2</font>"), nil, false, 0, false, nil},
    {markup.Parse("<font=HUDSmallNumberDisplay><color=20,255,20>Killfeed initialized.</color></font>"), nil, false, 0, false, nil},
}

rhud_ks_sublist = {
    {"npc_tripmine", "S.L.A.M."},
    {"rpg_missile", "RPG"},
    {"m9k_damascus", "DAMASCUS SWORD"},
    {"m9k_launched_ex41", "EX41"},
    {"m9k_fists", "FISTS"},
    {"m9k_thrown_m61", "GRENADE"},
    {"m9k_thrown_harpoon", "HARPOON"},
    {"m9k_improvised_explosive", "IED"},
    {"m9k_knife", "KNIFE"},
    {"m9k_m202_rocket", "M202"},
    {"m9k_launched_m79", "M79"},
    {"m9k_machete", "MACHETE"},
    {"m9k_gdcwa_matador_90mm", "MATADOR"},
    {"m9k_milkor_nade", "MILKOR GL"},
    {"m9k_released_poison", "NERVE GAS"},
    {"m9k_nitro_vapor", "NITRO GLYCERINE"},
    {"m9k_oribital_cannon", "ORBITAL CANNON"},
    {"m9k_proxy", "PROXIMITY MINE"},
    {"m9k_gdcwa_rpg_heat", "RPG"},
    {"m9k_thrown_sticky_grenade", "STICKY GRENADE"},
    {"m9k_suicide_bomb", "TIMED C4"},
    {"hunter_flechette", "FLECHETTE GUN"},
    {"tfa_cso2_c4_ent", "TFA C4"},
    {"tfa_cso2_firework_ent", "TFA FIREWORKS"},
    {"tfa_cso2_frag_ent", "TFA FRAG"},
    {"tfa_cso2_bag_ent", "TFA LUCKY BAG"},
    {"tfa_cso2_mk2_ent", "TFA MK2 GRENADE"},
    {"tfa_cso2_pg_ent", "TFA PARTY GRENADE"},
    {"tfa_cso2_heart_ent", "TFA VALENTINE GRENADE"},
    {"tfa_cso2_crossbow", "TFA CROSSBOW"},
    {"npc_satchel", "S.L.A.M."},
    {"crossbow_bolt", "CROSSBOW"},
    {"grenade_ar2", "SMG"},
    {"prop_combine_ball", "AR2"},
    {"gmod_wire_explosive", "WIRE EXPLOSIVE"},
    {"gmod_wire_turret", "WIRE TURRET"},
}

local skullPath = Material("r_hud/skull.png")

hook.Add("HUDPaint", "rhud_killfeed", function()
    for k, v in pairs(rhud_kf) do
        // local tw, th = draw.SimpleText(v[1], "HUDSmallNumberDisplay", 0, 0, Color(0, 0, 0, 0))
        local tw1 = v[1]:GetWidth()
        local tw2 = 0
        if v[2] != nil then
            tw2 = draw.SimpleText("w/ " .. v[2], "HUDSuperSmall", 0, 0, Color(0, 0, 0, 0))
        end
        local tw = math.max(tw2, tw1)

        local adj = 0
        local hadj = 0
        for x, l in pairs(rhud_kf) do
            if x == k then break end
            if l[2] != nil then hadj = hadj + 10 end
        end
        if v[2] != nil then adj = 10 end

        if v[3] == false then
            v[3] = true
            timer.Simple(5, function()
                v[5] = true
            end)
        end

        if v[5] == false then
            v[4] = Lerp(FrameTime() * 10, v[4], 255)
        else
            v[4] = Lerp(FrameTime() * 3, v[4], 0)
        end

        local ksadj = 0
        local kstw, ksth = 0, 0
        if v[6] != nil then
            kstw, ksth = draw.SimpleText(v[6], "HUDNumberDisplay", 0, 0, Color(0, 0, 0, 0))
            ksadj = kstw + 16 + 16
        end

        draw.RoundedBox(8, ScrW() - tw - 10 - 20 - ksadj, 105 + 33 * (k - 1) + hadj, tw + 20 + ksadj, 30 + adj, Color(20, 20, 20, v[4]))
        v[1]:Draw(ScrW() - 19 - ksadj, 112 + 33 * (k - 1) + hadj, 2, 0, v[4])
        if v[2] != nil then
            draw.SimpleText("w/ " .. v[2], "HUDSuperSmall", ScrW() - 19 - ksadj, 128 + 33 * (k - 1) + hadj, Color(255, 255, 255, v[4]), 2, 0)
        end
        if v[6] != nil then
            local temp_height_adj = 0
            if v[2] != nil then temp_height_adj = 5 end
            draw.SimpleText(v[6], "HUDNumberDisplay", ScrW() - 19, 112 + 33 * (k - 1) + hadj + temp_height_adj,  Color(255, 255, 255, v[4]), 2, 0)

            surface.SetDrawColor(Color(255, 255, 255, v[4]))
        	surface.SetMaterial(skullPath)
        	surface.DrawTexturedRect(ScrW() - 19 - 16 - kstw - 4, 112 + 33 * (k - 1) + hadj + temp_height_adj, 16, 16)
        end
        // draw.SimpleText(v[1], "HUDSmallNumberDisplay", ScrW() - 20, 113 + 33 * (k - 1), Color(255, 255, 255), 2, 2)

        if v[4] < 1 then
            table.remove(rhud_kf, k)
        end
    end
end)

net.Receive("rhud_senddeathkillfeed", function(len)
    -- data
    local info = net.ReadTable()
    local attacker = info.attacker
    local victim = info.victim
    local inflictor = info.inflictor

    -- checks
    local isWorld = false
    local isProp = false
    local isNPC = false
    if attacker == nil or !IsValid(attacker) then attacker = victim end
    if attacker == victim then inflictor = nil end
    if (attacker == nil or !IsValid(attacker)) and (victim == nil or !IsValid(victim)) then return end
    if attacker:GetClass() == "worldspawn" and inflictor == attacker then
        isWorld = true
    end
    if attacker:GetClass() == "prop_physics" then
        isProp = true
    end
    if attacker:IsNPC() or (IsValid(inflictor) and inflictor:IsNPC()) then
        isNPC = true
    end

    -- markup
    local attColor
    local attColorString
    if isWorld == false and isProp == false and isNPC == false and (attacker:IsPlayer() or inflictor:IsPlayer()) then
        attColor = team.GetColor(attacker:Team())
		local attNickEscaped = attacker:Nick()
		attNickEscaped = string.Replace(attNickEscaped, ">", "")
		attNickEscaped = string.Replace(attNickEscaped, "<", "")
        attColorString = "<color=" .. attColor["r"] .. "," .. attColor["g"] .. "," .. attColor["b"] .. ">" .. attNickEscaped .. "</color>"
    end
    local victimColor = team.GetColor(victim:Team())
	local victimNickEscaped = victim:Nick()
	victimNickEscaped = string.Replace(victimNickEscaped, ">", "")
	victimNickEscaped = string.Replace(victimNickEscaped, "<", "")
    local victimColorString = "<color=" .. victimColor["r"] .. "," .. victimColor["g"] .. "," .. victimColor["b"] .. ">" .. victimNickEscaped .. "</color>"

    local markupstr = "<font=HUDSmallNumberDisplay>"
    if attacker == victim then
        markupstr = markupstr .. victimColorString .. " killed themself</font>"
    elseif isWorld then
        markupstr = markupstr .. victimColorString .. " fell to death</font>"
    elseif attacker:IsPlayer() then
        markupstr = markupstr .. attColorString .. " killed " .. victimColorString .. "</font>"
    elseif isProp and string.sub(attacker:GetClass(), 1, 3) != "wac" then
		if IsValid(attacker) then 
			local owner = attacker:CPPIGetOwner()
			if IsValid(owner) then 
				local ownerColor = team.GetColor(owner:Team())
				local ownerNickEscaped = owner:Nick()
				ownerNickEscaped = string.Replace(ownerNickEscaped, ">", "")
				ownerNickEscaped = string.Replace(ownerNickEscaped, "<", "")
				local ownerColorString = "<color=" .. ownerColor["r"] .. "," .. ownerColor["g"] .. "," .. ownerColor["b"] .. ">" .. ownerNickEscaped .. "</color>"
				markupstr = markupstr .. victimColorString .. " was killed</font>"
				inflictor = ownerNickEscaped .. "\'s prop"
			else
				markupstr = markupstr .. victimColorString .. " was killed</font>"
				inflictor = "a world prop"
			end
		end 
        
    elseif isNPC then
        markupstr = markupstr .. victimColorString .. " was killed by an NPC</font>"
    else
        markupstr = markupstr .. victimColorString .. " died</font>"
    end

    local parse = markup.Parse(markupstr)

    if not isProp then
        if inflictor != nil and attacker != nil and IsValid(inflictor) and IsValid(attacker) then
            if attacker:IsPlayer() then
                if IsValid(attacker:GetActiveWeapon()) then
                    if attacker:GetActiveWeapon():GetClass() == inflictor:GetClass() or inflictor:IsPlayer() then
                        inflictor = string.upper(language.GetPhrase(attacker:GetActiveWeapon():GetPrintName()))
                    else
                        inflictor = string.upper(inflictor:GetClass())
                    end
                else
                    inflictor = string.upper(inflictor:GetClass())
                end
            else
                inflictor = nil
            end
        else
            inflictor = nil
        end
    end

    if inflictor != nil then
        for k, v in pairs(rhud_ks_sublist) do
            if string.upper(inflictor) == string.upper(v[1]) then inflictor = v[2] end
        end
    end

    -- killstreak
    local killstreak = nil
    if attacker:IsPlayer() then
        if attacker:SteamID64() != nil then
            kills = rhud_ks[attacker:SteamID64()]
            if kills != nil then
                if kills >= 5 then
                    killstreak = kills
                end
            end
        end
    end

    -- insert
    table.insert(rhud_kf, 1, {parse, inflictor, false, 0, false, killstreak})
end)

hook.Add("InitPostEntity", "rhud_initdeathnoticefunction", function()
    function GAMEMODE:AddDeathNotice(attacker, attackerTeam, inflictor, victim, victimTeam)
        return
    end
end)
