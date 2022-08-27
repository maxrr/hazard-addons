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

local tServerFiles = {
    "sv_base.lua",
    "sh_vgui.lua",
}
local tClientFiles = {
    "cl_base.lua",
    "sh_vgui.lua",
    "cl_fonts.lua",
    "cl_markup.lua",
    "vgui/gunselect.lua",
}
local tNetworkStrings = {
    "openmenu",
    "modify",
    "dump",
    "requestrefresh",
    "select",
    "denied",
}

rl_g_sMinimumDonorRank = "premium"
rl_g_iStandardLoadouts = 3
rl_g_tAllWeapons = rl_g_tAllWeapons or {}
local tVanillaWeapons = {
    'weapon_physgun',
    'weapon_357',
    'weapon_pistol',
    'weapon_bugbait',
    'weapon_crossbow',
    'weapon_crowbar',
    'weapon_frag',
    'weapon_physcannon',
    'weapon_ar2',
    'weapon_rpg',
    'weapon_slam',
    'weapon_shotgun',
    'weapon_smg1',
    'weapon_stunstick'
}

local tInvalidWeapons = {
    'bobs_gun_base',
    'bobs_nade_base',
    'bobs_scoped_base',
    'bobs_shotty_base',
    'fas2_base',
    'fas2_base_shotgun',
    'tfa_3dbash_base',
    'tfa_3dscoped_base',
    'tfa_akimbo_base',
    'tfa_base_template',
    'tfa_bash_base',
    'tfa_bow_base',
    'tfa_cssnade_base',
    'tfa_gun_base',
    'tfa_hdtf_claymore_base',
    'tfa_knife_base',
    'tfa_melee_base',
    'tfa_nade_base',
    'tfa_scoped_base',
    'tfa_shotty_base',
    'tfa_sword_advanced_base',
    'weapon_base',
    'weapon_doom3_base',
    'csgo_baseknife',
    'bobs_blacklisted',
    'weapon_simfillerpistol',
	'acf_base',
	'acf_basewep',
    'arccw_base',
    'arccw_base_melee',
    'arccw_base_nade'
}

hook.Add("InitPostEntity", "rl_loadout_setupweapontable", function()
    for k, v in pairs(weapons.GetList()) do
        rl_g_tAllWeapons[v['ClassName']] = true
    end
    for k, v in pairs(tVanillaWeapons) do
        rl_g_tAllWeapons[v] = true
    end
    for k, v in pairs(tInvalidWeapons) do
        rl_g_tAllWeapons[v] = nil
    end

    if CLIENT then
        rl_g_tAllWeapons_KeyValue = {}
        for k, v in pairs(rl_g_tAllWeapons) do
            table.insert(rl_g_tAllWeapons_KeyValue, k)
        end
        table.sort(rl_g_tAllWeapons_KeyValue)
    end
end)

if SERVER then
    for k, v in pairs(tServerFiles) do include("reality_loadout/" .. v) end
    for k, v in pairs(tClientFiles) do AddCSLuaFile("reality_loadout/" .. v) end
    for k, v in pairs(tNetworkStrings) do util.AddNetworkString("rl_loadout_" .. v) end

    resource.AddFile("materials/r_loadout/overlay.png")
    resource.AddFile("materials/r_loadout/lock_icon.png")
    resource.AddFile("materials/r_loadout/color_wheel_icon.png")
    resource.AddFile("materials/r_loadout/refresh_icon_1.png")
    resource.AddFile("materials/r_loadout/settings_icon_1.png")
    resource.AddFile("materials/r_loadout/back_icon_2.png")
    resource.AddFile("materials/r_loadout/delete_icon.png")
    resource.AddFile("materials/r_loadout/paste_icon_4.png")
    resource.AddFile("materials/r_loadout/add_icon_2.png")
    resource.AddFile("materials/r_loadout/select_icon_3.png")
    resource.AddFile("materials/r_loadout/edit_icon_2.png")
    resource.AddFile("materials/r_loadout/loading_icon_1.png")
    resource.AddFile("materials/r_loadout/continue_icon_1.png")
    resource.AddFile("sound/r_loadout/click.wav")
elseif CLIENT then
    for k, v in pairs(tClientFiles) do include("reality_loadout/" .. v) end
end

-- player:CheckGroup()
