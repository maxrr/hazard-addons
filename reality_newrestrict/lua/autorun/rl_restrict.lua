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

rlr_config = {
    ["roles"] = {
        ["admin"] = {
            ["owner"] = true,
            ["ownerassistant"] = true,
            ["superadmin"] = true,
            ["admin"] = true,
        },
        ["reload"] = {
            ["owner"] = true,
            ["ownerassistant"] = true,
            ["superadmin"] = true,
        },
        ["all"] = {
            "*",
            "owner",
            "ownerassistant",
            "superadmin",
            "admin",
            "moderator",
            "helper",
            "premiumplus",
            "premium",
            "veteran",
            "addict",
            "dedicated",
            "trusted",
            "member",
            "user",
        },
        ["replace"] = {
            ["*"] = "All",
            ["owner"] = "Developer",
            ["ownerassistant"] = "Community Manager",
            ["superadmin"] = "Manager",
            ["admin"] = "Admin",
            ["moderator"] = "Moderator",
            ["helper"] = "Helper",
            ["premiumplus"] = "Premium+",
            ["premium"] = "Premium",
            ["veteran"] = "Veteran",
            ["addict"] = "Addict",
            ["dedicated"] = "Dedicated",
            ["trusted"] = "Regular",
            ["member"] = "Member",
            ["user"] = "Guest",
        }
    },
    ["limits"] = {
//        ["ownerassistant"] = {
//            prop = 6666,
//            npc = 100,
//        },
//        ["admin"] = {
//            prop = 1500,
//            npc = 50,
//        },
//        ["premiumplus"] = {
//            prop = 1000,
//            npc = 3,
//        },
//        ["premium"] = {
//            prop = 750,
//        },
//        ["user"] = {
//            prop = 500,
//        },
    },
    ["loadout"] = {
        ["user"] = {
            //"none",
            //"keypad_cracker",
        }
    },
}

function rlr_config.easyKeyTable(tab)
    local nt = {}
    for k, v in pairs(tab) do
        nt[v] = true
    end
    return nt
end

function rlr_config.roleIndex(role)
    for k, v in pairs(rlr_config.roles.all) do
        if role == v then return k end
    end
    return nil
end

function rlr_config.nameByIndex(index)
    for k, v in pairs(rlr_config.roles.all) do
        if k == index then return v end
    end
end

function rlr_config.roleDisplay(role)
    return rlr_config.roles.replace[role]
end

local serverFiles = {
    "sv_base.lua",
    "sv_restrict.lua",
    "sv_block.lua",
    "sv_custom_dupe.lua",
}
local clientFiles = {
    "cl_base.lua",
    "cl_menu.lua",
    "cl_spawnmenu.lua",
}
local networkStrings = {
    "cannotSpawnProp",
    "openMenu",
    "sendMenuData",
    "thresholdNotAdmin",
    "thresholdInvalid",
    "thresholdSuccess",
    "modifyRestriction",
    "confirmRestriction",
    "addRestriction",
    "deleteRestriction",
    "denySpawn",
    "denyPickup",
    "invalidSync",
    "needsReload",
    "restrictionInvalid",
    "cannotOpenMenu",
    "adminReloadedFiles",
    "toAdminReportConflicts",
    "dumpTable",
    "requestRedump",
}

if SERVER then
    for k, v in pairs(serverFiles) do include("rl_restrict/" .. v) end
    for k, v in pairs(clientFiles) do AddCSLuaFile("rl_restrict/" .. v) end
    for k, v in pairs(networkStrings) do util.AddNetworkString("rl_" .. v) end
elseif CLIENT then
    for k, v in pairs(clientFiles) do include("rl_restrict/" .. v) end
end
