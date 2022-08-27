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

// ~reality (squarebush#0001)
// TODO: uncomment all -- lines
if CLIENT then 
    local done = false  // are we done with our initialization?
    local timeout = 30  // seconds before we get an error message

    local function prettyprint(str, err)
        if err then 
            --chat.AddText(Color(228, 228, 288), os.date('%H:%M:%S'), Color(255, 50, 50), ' [!!] ', Color(236, 132, 114), '[MyHG] ', Color(228, 228, 228), str)
        else 
            --chat.AddText(Color(228, 228, 288), os.date('%H:%M:%S'), Color(193, 236, 92), ' [MyHG] ', Color(228, 228, 228), str)
        end 
    end 

    hook.Add('InitPostEntity', 'reality_myhgstatsync_notifyServer', function()
        net.Start('reality_myhgstatssync_initial')
        net.SendToServer()

        // create our net receiver
        net.Receive('reality_myhgstatssync_initial', function()
            done = true
        end)

        // make our timeout func
        timer.Simple(timeout, function()
            if not done then 
                prettyprint('The server did not respond to your MyHG sync request. Please rejoin and contact a manager or developer if this reoccurs.', 1)
            end 
        end)
    end)

    net.Receive('reality_myhgstatssync_print', function()
        local str = net.ReadString()
        local err = net.ReadBool()
        prettyprint(str, err)
    end)
end 