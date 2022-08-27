/*function rlr_config.customDupeFunc(trace, TOOL)
    local dupe = TOOL:GetOwner().CurrentDupe
    if ( !dupe ) then return end

    local SpawnCenter = trace.HitPos
    SpawnCenter.z = SpawnCenter.z - dupe.Mins.z

    local SpawnAngle = TOOL:GetOwner():EyeAngles()
    SpawnAngle.pitch = 0
    SpawnAngle.roll = 0

    duplicator.SetLocalPos( SpawnCenter )
    duplicator.SetLocalAng( SpawnAngle )

    local problems = {}
    local hasFirstNotified = false
    local ply = TOOL:GetOwner()
    for k, v in pairs(dupe.Entities) do
        local identifier, itype = v.Class, "ent"
        if identifier == "prop_physics" then identifier, itype = v.Model, "prop" end
        if v.VehicleName != nil then identifier, itype = v.VehicleName, "vehicle" end

        PrintTable(v)

        if itype == "prop" or itype == "vehicle" then
            if ply:canAccess(identifier, itype) == false then
                hasFirstNotified = true
                table.remove(dupe.Entities, k)
                local cl1 = Color(255, 80, 80)
                local cl2 = Color(255, 180, 180)
                if hasFirstNotified == false then
                    MsgC("yes")
                end
            end
        end
    end

    DisablePropCreateEffect = true
        local Ents, Constraints = duplicator.Paste( TOOL:GetOwner(), dupe.Entities, dupe.Constraints )
    DisablePropCreateEffect = nil

    duplicator.SetLocalPos( Vector( 0, 0, 0 ) )
    duplicator.SetLocalAng( Angle( 0, 0, 0 ) )

    undo.Create( "Duplicator" )
        for k, ent in pairs( Ents ) do
            undo.AddEntity( ent )
        end
        for k, ent in pairs( Ents )	do
            TOOL:GetOwner():AddCleanup( "duplicates", ent )
        end
        undo.SetPlayer( TOOL:GetOwner() )
    undo.Finish()

    return true
end
*/
