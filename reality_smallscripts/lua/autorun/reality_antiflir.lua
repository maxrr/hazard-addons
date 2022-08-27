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

if CLIENT then 

	timer.Create("rantiflir", 5, 0, function()
		
		concommand.Remove("flir_enable")
		if FLIR and FLIR.enabled then FLIR.enable(false) end 
		
	end)

	concommand.Remove('adjust_voice_volume')

	concommand.Add('adjust_voice_volume', function(ply, _, args)
		if #args < 2 then 
			print('Please specify both a user and a volume')
			return
		end 

		if not tonumber(args[2]) then 
			print('Please specify a number to change the player\'s voice volume to')
			return
		end 

		local toSearch = string.lower(args[1])
		local vol = args[2]
		local ply

		for k, v in ipairs(player.GetHumans()) do
			if string.find( string.lower(v:Nick()), toSearch) then 
				ply = v;
				break;
			end 
		end

		if ply then 
			ply:SetVoiceVolumeScale(args[2])
		else
			print('Player not found')
			return
		end 
	end, function(cmd, stringargs)
		local tbl = {}
		stringargs = string.sub(stringargs, 2)
		for k, v in ipairs(player.GetAll()) do
			if string.find( string.lower(v:Nick()), string.lower(stringargs) ) then 
				table.insert(tbl, 'adjust_voice_volume "' .. v:Nick() .. '" ' .. v:GetVoiceVolumeScale())
			end 
		end
		return tbl
	end, "Sets a player's voice volume scale (0.0 is 0%, 1.0 is 100%)")

	concommand.Add('reset_voice_volume', function()
		for k, v in ipairs(player.GetAll()) do
			v:SetVoiceVolumeScale(1)
		end
	end, nil, "Resets everyone's voice volume back to 1.0")
	
end 