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

// queues http.Fetch requests until we are sure that http.Fetch is available
// https://wiki.facepunch.com/gmod/Lua_Hooks_Order

if SERVER then 
    HTTP_ALREADY_QUEUED = HTTP_ALREADY_QUEUED or 'false'

    if HTTP_ALREADY_QUEUED == 'false' then
        HTTP_ALREADY_QUEUED = 'true'

        local httpQueue = {};
        local oldHttpFetchFunc = http.Fetch;
        http.Fetch = function(...)
            local arg = { ... }
            table.insert(httpQueue, {arg})
            MsgC(Color(69, 200, 69), 'Queued http.Fetch to ' .. (arg[1] or '(unknown)') .. ', will execute later\n')
        end

        hook.Add("Tick", "reality_dumphttpqueue", function()
            MsgC(Color(69, 200, 69), 'Dequeueing all prior http.Fetch...\n')
            for k, v in ipairs(httpQueue) do
                oldHttpFetchFunc(unpack(v))
            end
            http.Fetch = oldHttpFetchFunc
            MsgC(Color(69, 200, 69), "All http.Fetch dequeued, http.Fetch reverted\n")
            hook.Remove("Tick", "reality_dumphttpqueue")
        end)
    end
end