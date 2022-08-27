if SERVER then
	rlwac.customIsAdmin = function(ply)
		local rank = ply:GetUserGroup()
		local isAdmin = table.HasValue(rlwac.adminranks, rank)
		//print(isAdmin)
		if isAdmin then return true else return false end
	end
	
	rlwac.isWac = function(class)
		if string.sub(class, 1, 3) == "wac" and not class == "wac_aircraft_maintenance" then 
			
		end
	end

    hook.Add("PlayerSpawnSENT", "rlwac_int", function(ply, class)
        if string.sub(class, 1, 3) == "wac" then
            if ply:GetNWInt("rlwac_dep", 0) > 0 then
                net.Start("rlwac_nospawn")
                net.Send(ply)
                return false
            end
        end
    end)

    hook.Add("PlayerSpawnedSENT", "rlwac_spawned", function(ply, ent)
        if string.sub(ent:GetClass(), 1, 3) == "wac" then
            if ply:GetNWInt("rlwac_dep", 0) > 0 then
                // How did you get here?
                if IsValid(ent) then
	                ent:Remove()
	            end
            else
                ply:SetNWInt("rlwac_dep", 1)
            end
        end
	end)

    hook.Add("EntityRemoved", "rlwac_rem", function(ent)
        if string.sub(ent:GetClass(), 1, 3) == "wac" then
            local owner = ent:CPPIGetOwner()
            if owner != nil then
				if timer.Exists(owner:SteamID64() .. "_rlwacdel") then timer.Remove(owner:SteamID64() .. "_rlwacdel") end 
                owner:SetNWInt("rlwac_dep", 0)
            end
        end
    end)

    hook.Add("EntityTakeDamage", "rlwac_dmg", function(ent, dmg)
        local class = ent:GetClass()
        local disabled = tostring(ent.disabled or "not set")
		
        if disabled == "true" then
            local owner = ent:CPPIGetOwner()
            if not table.HasValue(rlwac.todelete, ent) then
                if owner != nil then
                    net.Start("rlwac_willdelete")
                    net.Send(owner)
                end
                table.insert(rlwac.todelete, 1, ent)
				
                timer.Create(owner:SteamID64() .. "_rlwacdel", rlwac.deltime, 1, function()
                    table.RemoveByValue(rlwac.todelete, ent)
					
					if IsValid(ent) then 
						ent:Remove()
					end
					
                    if owner != nil then
                        net.Start("rlwac_deleted")
                        net.Send(owner)
						owner:SetNWInt("rlwac_dep", 0)
                    end
                end)
            end
        end
    end)
	
	hook.Add("PhysgunPickup", "rlwac_phys", function(ply, ent)
		local owner = ent:CPPIGetOwner()
		if owner != nil then 
			if ply == owner then 
				if string.sub(ent:GetClass(), 1, 3) == "wac" then 
					return true
				end
			end
		end
	end)
	
	hook.Add("OnPhysgunFreeze", "rlwac_nofreeze", function(weapon, physobj, ent, ply)
		if string.sub(ent:GetClass(), 1, 3) == "wac" then 
			if rlwac.customIsAdmin(ply) == true then 
				return true 
			else 
				return false
			end
		end
	end)

    /*concommand.Add("rlwac_reset", function(ply, cmd, args)
        ply:SetNWInt("rlwac_dep", 0)
    end)*/
else
    net.Receive("rlwac_nospawn", function()
        chat.AddText(Color(255, 102, 102), "Woah! You already have a WAC aircraft deployed.")
    end)

    net.Receive("rlwac_deleted", function()
        chat.AddText(Color(255, 102, 102), "Your WAC aircraft was auto-deleted for being destroyed.")
    end)

    net.Receive("rlwac_willdelete", function()
        chat.AddText(Color(255, 102, 102), "Your WAC aircraft is destroyed and will be auto-deleted in ", Color(155, 55, 55), tostring(rlwac.deltime), Color(255, 102, 102), " seconds.")
    end)
end
