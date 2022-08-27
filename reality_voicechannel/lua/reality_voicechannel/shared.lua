RLVC = RLVC or {}

local function correctFormatting(tab)
    local new = {}
    for k, v in pairs(tab) do
        new[v] = true
    end
    return new
end

RLVC.defaultChannel = "global"
RLVC.establishedChannels = {
    global = true,
    proximity = true,
}

RLVC.staffRanks = correctFormatting({
    "owner",
    "ownerassistant",
    "manager",
    "superadmin",
    "admin",
    "moderator",
    "helper",
})

RLVC.donorRanks = correctFormatting({
    "premiumplus",
    "premium",
})
