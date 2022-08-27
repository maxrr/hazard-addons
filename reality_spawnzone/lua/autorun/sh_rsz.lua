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

rsz = rsz or {}

function rsz.vectorRound(x, y, z)
    return Vector(math.Round(x), math.Round(y), math.Round(z))
end

function rsz.noKVToQA(tab)
    local temp = {}
    for k, v in pairs(tab) do
        if type(v) == "string" then temp[v] = true end
    end
    return temp
end
