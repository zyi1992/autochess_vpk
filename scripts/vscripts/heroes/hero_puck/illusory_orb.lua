--[[
	Author: Ractidous
	Date: 02.16.2015.
	Create a linear projectile, then keep it tracked.
]]
function CastIllusoryOrb( event )
	
	local caster	= event.caster
	local ability	= event.ability
	local point		= event.target_points[1]

	local radius			= event.radius
	local maxDist			= event.max_distance
	local orbSpeed			= event.orb_speed
	local visionRadius		= event.orb_vision
	local visionDuration	= event.vision_duration
	local numExtraVisions	= event.num_extra_visions

	local travelDuration	= maxDist / orbSpeed
	local extraVisionInterval = travelDuration / numExtraVisions

	local casterOrigin		= caster:GetAbsOrigin()
	local targetDirection	= ( ( point - casterOrigin ) * Vector(1,1,0) ):Normalized()
	local projVelocity		= targetDirection * orbSpeed

	local startTime		= GameRules:GetGameTime()
	local endTime		= startTime + travelDuration

	local numExtraVisionsCreated = 0
	local isKilled		= false

	-- Make Ethereal Jaunt active
	-- local etherealJauntAbility = ability.illusory_orb_etherealJauntAbility
	-- etherealJauntAbility:SetActivated( true )

	-- Create linear projectile
	local projID = ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= event.proj_particle,
		vSpawnOrigin		= casterOrigin,
		fDistance			= maxDist,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= endTime,
		bDeleteOnHit		= false,
		vVelocity			= projVelocity,
		bProvidesVision		= true,
		iVisionRadius		= visionRadius,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	--print("projID = " .. projID)

	-- Create sound source
	local thinker = CreateUnitByName( "npc_dota_thinker", casterOrigin, false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, thinker, event.proj_modifier, { duration = -1 } )

end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Upgrade the sub ability and make inactive it.
]]
function OnUpgrade( event )

end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Cast Ethereal Jaunt.
]]
function CastEtherealJaunt( event )

end



--[[
	Author: Ractidous
	Date: 13.02.2015.
	Stop a sound on the target unit.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.target )
end