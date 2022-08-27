Regtitles = Regtitles or {}

util.AddNetworkString("rsig_register_title")

function registerTitle(iden, print, effect, cost, color)
    if type(iden) != "string" then print("rsig-titles ERROR: iden is not type string") end
    if type(print) != "string" then print("rsig-titles ERROR: print is not type string") end
    if type(effect) != "string" then print("rsig-titles ERROR: effect is not type string") end  
    if type(cost) != "number" then print("rsig-titles ERROR: cost is not type integer") end  
    if type(color) != "table" then print("rsig-titles ERROR: color is not type color") end  

    Regtitles[iden] = {
        print = print,
        effect = effect,
        cost = cost,
        color = color
    }
end

hook.Add("PlayerInitialSpawn", "registerTitlesOnPlayerSpawn", function(ply)
    net.Start("rsig_register_title")
    net.WriteTable(Regtitles)
    net.Send(ply)
end)