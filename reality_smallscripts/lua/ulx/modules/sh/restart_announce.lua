local CATEGORY_NAME = "HG Custom"

function ulx_announcerestart(calling_ply, restart_time)
	RunConsoleCommand('ScheduleRestart', restart_time)
	ulx.fancyLogAdmin(calling_ply, "#A has announced a server restart")
end 
local ulx_announcerestart_cmd = ulx.command(CATEGORY_NAME, "ulx announcerestart", ulx_announcerestart, "!announcerestart", false)
ulx_announcerestart_cmd:addParam{type = ULib.cmds.NumArg, default=10, hint = "Minutes until restart"}
ulx_announcerestart_cmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
ulx_announcerestart_cmd:help("Notifies players about an upcoming restart.")

function ulx_cancelrestartannouncements(calling_ply)
	RunConsoleCommand('CancelRestartAnnouncements')
	ulx.fancyLogAdmin(calling_ply, "#A has cleared all server restart announcements")
end 
local ulx_cancelrestartannouncements_cmd = ulx.command(CATEGORY_NAME, "ulx announcerestartcancel", ulx_cancelrestartannouncements, "!announcerestartcancel", false)
ulx_cancelrestartannouncements_cmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
ulx_cancelrestartannouncements_cmd:help("Cancels all player-made announcements of an upcoming restart.")

if SERVER then 
	util.AddNetworkString("BuildmodeForcechanged")
end

function ulx_forcebuild(calling_ply, target_ply, build_mode)
	target_ply:setBuild(build_mode)
	if build_mode then 
		ulx.fancyLogAdmin(calling_ply, "#A has forced #T to enable buildmode", target_ply)
	else
		ulx.fancyLogAdmin(calling_ply, "#A has forced #T to disable buildmode", target_ply)
	end 
	if SERVER then 
		net.Start("BuildmodeForcechanged")
			net.WriteBool(build_mode)
		net.Send(target_ply)
	end 
end
local ulx_forcebuild_cmd = ulx.command(CATEGORY_NAME, "ulx forcebuild", ulx_forcebuild, "!forcebuild")
ulx_forcebuild_cmd:addParam{type=ULib.cmds.PlayerArg}
ulx_forcebuild_cmd:addParam{type=ULib.cmds.BoolArg, default=true, hint="Force into build?"}
ulx_forcebuild_cmd:defaultAccess(ULib.ACCESS_SUPERADMIN)
ulx_forcebuild_cmd:help("Force a player into or out of buildmode.")