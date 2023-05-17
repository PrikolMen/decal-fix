-- Libraries
local render = render
local table = table
local hook = hook

-- Variables
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local EyePos = EyePos
local ipairs = ipairs

local addonName = "DecalFix"
local entities = {}

hook.Add( "OnEntityCreated", addonName, function( entity )
    if entity:IsNPC() or entity:IsNextBot() or entity:IsRagdoll() then
        table.insert( entities, entity )
    end
end )

hook.Add( "CreateClientsideRagdoll", addonName, function( entity, ragdoll )
    table.RemoveByValue( entities, entity )
    table.insert( entities, ragdoll )
end )

local maxDistance = cvars.Number( "r_flashlightfar", 1024 ) ^ 2
cvars.AddChangeCallback( "r_flashlightfar", function( _, __, value )
    maxDistance = ( tonumber( value ) or 1024 ) ^ 2
end, addonName )

hook.Add( "PreDrawEffects", addonName, function()
    if not LocalPlayer():FlashlightIsOn() then return end
    local eyePos = EyePos()

    render.SetBlend( 0 )

    for index, entity in ipairs( entities ) do
        if not IsValid( entity ) then
            table.remove( entities, index )
            break
        end

        if eyePos:DistToSqr( entity:GetPos() ) <= maxDistance then
            entity:DrawModel()
        end
    end

    render.SetBlend( 1 )
end )