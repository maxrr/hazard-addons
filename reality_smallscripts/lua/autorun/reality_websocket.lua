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

/*if SERVER then 
    require("bromsock")

    print("Starting HGB_WS")

    print(BromSock)

    local hostPort = 2009

    if HGB_WS then HGB_WS:Close() end
    HGB_WS = BromSock(BROMSOCK_UDP)

    HGB_WS:SetCallbackReceiveFrom(function(sockobj, packet, ip, port)
        print('[WS] Received: ', packet, ip, port)

        local rsa = packet:ReadStringAll()

        print('[WS] R_Str: ', rsa)

        packet:WriteString('From server')
        HGB_WS:SendTo(packet, ip, port)

        HGB_WS:ReceiveFrom()
    end)

    HGB_WS:Bind(hostPort)
    HGB_WS:ReceiveFrom()

    print("HGB_WS hosted on port " .. hostPort)
end*/