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

local files = {
    cl = {
        //"client.lua",
        "network_cl.lua",
        //"context_current_menu.lua",
        "font.lua",
        "voicepanel.lua",
    },
    sv = {
        "server.lua",
    },
    sh = {
        "shared.lua",
    }
}

for k, v in pairs(files) do for l, x in pairs(v) do table.remove(v, l); table.insert(v, l, "reality_voicechannel/" .. x) end end

if SERVER then
    for k, v in pairs(files.sh) do AddCSLuaFile(v); include(v) end
    for k, v in pairs(files.cl) do AddCSLuaFile(v) end
    for k, v in pairs(files.sv) do include(v) end
elseif CLIENT then
    for k, v in pairs(files.sh) do include(v) end
    for k, v in pairs(files.cl) do include(v) end
end
 