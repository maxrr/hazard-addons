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
    include("rbuild/sv.lua")
    AddCSLuaFile("rbuild/cl.lua")
    AddCSLuaFile("rbuild/float2.lua")
else
    //include("rbuild/sh.lua") //
    include("rbuild/cl.lua")
    include("rbuild/float2.lua")
end
