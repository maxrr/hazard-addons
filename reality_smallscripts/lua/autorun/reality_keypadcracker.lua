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

if SERVER then 

    // stop people from switching to the keypad cracker when in buildmode (also works on spawn)
    hook.Add("PlayerSwitchWeapon", "blockBuildmodeKeypads", function(ply, old, new)

		local plyActiveWeapon = ply:GetActiveWeapon()

		if plyActiveWeapon != nil then 

			if new:GetClass() == "keypad_cracker" then 

				if ply:isBuild() then 

					ply:ChatPrint("You cannot use the keypad cracker in buildmode.")
					return true

				end 

			end 

		end 

	end)

	// stop people from holding keypad cracker and switching to buildmode
	hook.Add("RBuildModeChange", "blockBuildmodeKeypads", function(ply, newMode)
	
		if newMode == true then 

			local plyActiveWeapon = ply:GetActiveWeapon()

			if plyActiveWeapon != nil then 

				if plyActiveWeapon:GetClass() == "keypad_cracker" then 

					local weps = ply:GetWeapons()
					ply:SetActiveWeapon(nil)
					ply:ChatPrint("You cannot use the keypad cracker in buildmode.")

				end 

			end 

		end

	end)

end 