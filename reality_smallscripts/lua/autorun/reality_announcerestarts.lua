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

    local function plural(num)
		if num == 1 then return "" else return "s" end 
	end 

	net.Receive("PrintRestartAnnouncementNotif", function()
		local hours = net.ReadUInt(6)
		local mins = net.ReadUInt(6)

		local l = hours * 60 + mins

		local timeString = l .. " minute" .. plural(l)
					
		if l >= 60 then 

			if l % 60 != 0 then 

				timeString = math.floor(l / 60) .. " hour" .. plural(math.floor(l / 60)) .. " and " .. l % 60 .. " minute" .. plural(l % 60)

			else 

				timeString = l / 60 .. " hour" .. plural(l / 60)

			end 

		end

		chat.AddText(Color(255, 0, 0), "The server will restart in ", timeString, "!")

		surface.PlaySound("buttons/bell1.wav")
		surface.PlaySound("buttons/blip1.wav")

		timer.Simple(0.4, function()
			surface.PlaySound("buttons/bell1.wav")
			timer.Simple(0.4, function()
				surface.PlaySound("buttons/bell1.wav")
			end)
		end)

	end)

else 

    util.AddNetworkString("PrintRestartAnnouncementNotif")

	local function announceRestart(timeHours, timeMins) 

		//for _, v in pairs(player.GetAll()) do

			//if v:IsAdmin() then 

				net.Start("PrintRestartAnnouncementNotif")
					net.WriteUInt(timeHours, 6)
					net.WriteUInt(timeMins, 6)
				net.Broadcast(v)

			//end 

		//end

	end 

	local restartTimes = {
		{
			h = 3,
			m = 0
		}
	}

	local notifyMinutesBefore = {
		3, 4, 5, 10, 20, 30, 60
	}

	concommand.Add("CancelRestartAnnouncements", function()
		for k, v in pairs(restartTimes) do
			if v.addedByCommand == true then 
				restartTimes[k] = nil
			end 
		end 
	end)

	concommand.Add("ScheduleRestart", function(_, _, args)
		if #args < 1 then 
			print("Please supply minutes until restart")
			return
		end 

		if (not tonumber(args[1])) then 

			print("Please supply a valid number")
			return

		end 

		local hour = os.date("%H")
		local minute = os.date("%M") + args[1]

		while (minute >= 60) do
			hour = hour + 1
			minute = minute - 60
		end 

		table.insert(restartTimes, {
			h = hour,
			m = minute,
			addedByCommand = true
		})

	end)

	timer.Create("ServerRestartWarning", 3, 0, function()
		
		local hour = os.date("%H")
		local minute = os.date("%M")

		for k, x in pairs(restartTimes) do

			local diff = (x.h - hour) * 60  + (x.m - minute)
			local diff2 = ((x.h + 24) - hour) * 60 + (x.m - minute)

			local numberToCompare = diff

			if (diff < 0) then 
				numberToCompare = diff2
			end 

			for _, l in pairs(notifyMinutesBefore) do 

				if numberToCompare <= l and ((x.lastNotifiedIncrement != nil and x.lastNotifiedIncrement > l) or x.lastNotifiedIncrement == nil) then 
					
					l = numberToCompare
					restartTimes[k].lastNotifiedIncrement = l

					announceRestart(math.floor(l / 60), l % 60)

				end 

			end

		end 

	end)

end