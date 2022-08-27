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
    local meta = getmetatable("Player")
    rlip_cache = rlip_cache or {}
    rlip_reg = rlip_reg or {}

    local filePath = "rl_ip/" .. os.date("%Y_%m", os.time()) .. ".txt"
    if not file.IsDir("rl_ip", "DATA") then file.CreateDir("rl_ip") end
    if not file.Exists(filePath, "DATA") then file.Write(filePath, "") end

    hook.Add("PlayerConnect", "rliplogcnct", function(name, ip)
        rlip_cache[name] = ip
    end)
    hook.Add("PlayerInitialSpawn", "rliplogspwn", function(ply)
        local result = {}
        if rlip_cache[ply:Nick()] != nil then
            for k, v in pairs(player.GetAll()) do
                if v:Nick() == ply:Nick() then
                    table.insert(result, { v, rlip_cache[ply:Nick()] })
                    table.insert(rlip_reg, { ply = v, ip = rlip_cache[ply:Nick()] })
                end
            end
        end
        for k, v in pairs(result) do
            file.Append(filePath, "\n[" .. os.date("%m/%d|%T", os.time()) .. "] " .. v[1]:SteamID() .. " as (" .. v[1]:Nick() .. ")" .. " connected with IP: " .. v[2])
        end
    end)

    function meta:RLGetIP()
        for k, v in pairs(rlip_reg) do
            if v[1] == self then
                return v[2]
            end
        end
        return nil
    end
end
