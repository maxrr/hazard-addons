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

if not SERVER then return end

local BlacklistAmmo = {
    ["RPG_Round"] = true,
    ["XBowBolt"] = true,
    ["Grenade"] = true,
    ["slam"] = true,
    ["SMG1_Grenade"] = true,

    ["AirboatGun"] = true, --TFA Rockets
    ["cso2_20mm"] = true,
    ["cso2_40mm"] = true,
    ["cso2_fraggrenade"] = true,
    ["cso2_flashbang"] = true,
    ["cso2_firework"] = true,
    ["cso2_smoke"] = true,
    ["cso2_rpg"] = true,

    ["40mmGrenade"] = true,
    ["nitroG"] = true,
    ["NerveGas"] = true,
    ["C4Explosive"] = true,
    ["ProxMine"] =true,
    ["Improvised_Explosive"] = true,
    ["StickyGrenade"] = true,
    ["Harpoon"] = true,
    ["SatCannon"] = true,
}

local function isPrimaryBlocked(wep)
    if not wep then return true end
    local AmmoID = wep:GetPrimaryAmmoType()
    if AmmoID != -1 then
        return 
    end
    return false
end

local function InfiniteAmmo()
    for k,v in pairs (player.GetAll()) do
        weapon = v:GetActiveWeapon()
        if IsValid(weapon) then
            local primAmmoType = weapon:GetPrimaryAmmoType()
            if not BlacklistAmmo[game.GetAmmoName(primAmmoType)] then
                local maxClip = weapon:GetMaxClip1()

                if maxClip == -1 then
                    maxClip = 100
                end

                if maxClip <= 0 and primAmmoType ~= -1 then
                    maxClip = 1
                end

                if primAmmoType ~= -1 then
                    v:SetAmmo( maxClip, primAmmoType, true)
                end
            end
        end
    end
end
//hook.Add("Think", "InfiniteAmmo", InfiniteAmmo)

hook.Add("InitPostEntity", "rll_infammo_fromewa", function()
    timer.Create("rll_assertinfammo", 0, 0.1, InfiniteAmmo)
end)
