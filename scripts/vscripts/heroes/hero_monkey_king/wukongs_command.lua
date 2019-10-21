function castParticles( keys )
	local caster = keys.caster
	local ability = keys.caster

--	ability.startPfx = ParticleManager:CreateParticle("", PATTACH_ABSORIGIN_FOLLOW, caster)
--	ParticleManager:SetParticleControl(int_1,int_2,Vector_3)
end

function inturreputed( keys )
	local ability = keys.ability
	ParticleManager:DestroyParticle(ability.startPfx, false)
	ParticleManager:ReleaseParticleIndex(ability.startPfx)
	ability.startPfx = nil
end

function MakeMonkeys( keys )
	local ability = keys.ability
	if ability.monkeys then return end

	ability.monkeys = {["idle"] = {}, ["attack"] = {}}
	local caster = keys.caster
	ability.interior = ability:GetSpecialValueFor("interior_soldiers")
	ability.exterior = ability:GetSpecialValueFor("exterior_soldiers")

	--create one monkey per second until they are all made
	local i = 0
	ability.monkeyTimer = Timers:CreateTimer(
	function()
		i=i+1
		--create monkey
		ability.monkeys["idle"][i] = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_singlemonkey.vpcf", PATTACH_WORLDORIGIN, caster)
		ability.monkeys["attack"][i] = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_singlemonkey_attack.vpcf", PATTACH_WORLDORIGIN, caster)

		--out of sight, out of mind (lul, volvo)
		ParticleManager:SetParticleControl(ability.monkeys["idle"][i], 0, Vector(0,0,-200))
		ParticleManager:SetParticleControl(ability.monkeys["attack"][i], 0, Vector(0,0,-200))
		if i < ability.interior+ability.exterior then
			return 1.0
		end
	end)
end

--ensure monkeys exist if someone casts ult before they are finished being made
local function EmergencyMonkeys( caster, ability )
	ability.interior = ability:GetSpecialValueFor("interior_soldiers")
	ability.exterior = ability:GetSpecialValueFor("exterior_soldiers")
	if ability.monkeys then
		-- monkeys have already finished, do nothing
		if #ability.monkeys["idle"] >= ability.interior+ability.exterior then
			return
		end
		--monkeys are in the process of being made, stop timer and do it quick
		Timers:RemoveTimer(ability.monkeyTimer)
	end
	-- make monkeys
	ability.monkeys = ability.monkeys or {["idle"] = {}, ["attack"] = {}}
	for i=#ability.monkeys["idle"]+1,ability.interior+ability.exterior do
		ability.monkeys["idle"][i] = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_singlemonkey.vpcf", PATTACH_WORLDORIGIN, caster)
		ability.monkeys["attack"][i] = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_furarmy_singlemonkey_attack.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(ability.monkeys["idle"][i], 0, Vector(0,0,-200))
		ParticleManager:SetParticleControl(ability.monkeys["attack"][i], 0, Vector(0,0,-200))
	end
end

function WukongStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	EmergencyMonkeys(caster, ability)

--	local ringPfx = ParticleManager:CreateParticle("", PATTACH_WORLDORIGIN, caster)

	local angle1 = ability:GetSpecialValueFor("interior_angle")
	local angle2 = ability:GetSpecialValueFor("exterior_angle")



	for i=1,ability.interior do
		ParticleManager:SetParticleControl(ability.monkeys["idle"][i], 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ability.monkeys["attack"][i], 0, caster:GetAbsOrigin()+Vector(100,0,0))
	end
	for i=ability.interior+1,ability.exterior do
		ParticleManager:SetParticleControl(ability.monkeys["idle"][i], 0, caster:GetAbsOrigin())
	end
end

--move monkeys around and perform attacks if units are nearby
-- probably gunna use a single monkey for actual attacks, maybe even main hero
function MonkeyThinker()
end

function WukongEnd()
	--hide monkeys

	--disable attack thinkers
end









function WStart( keys )
	--ensure monkeys exist(try to use valves?)

	--move monkeys to underneath the caster

	--move monkeys to caster

	--order inner monkeys movement, start attack thinkers

	--order outer monkeys movement, start attack thinkers

end

function CloneAtkLanded( keys )
	local clone = keys.attacker
	local target = keys.target
	local mainClone = keys.ability.mainClone

	local attackInterval = keys.ability:GetSpecialValueFor("soldiers_attack_speed")

	--start clone attack cd
	local cloneMod = clone:FindModifierByName("modifier_monkey_clone_think")
	if cloneMod then
		cloneMod:SetStackCount(attackInterval*10) --Randomtype
	end
	clone:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)

	if mainClone then
		print("smack!")
		mainClone:PerformAttack(target, true, true, true, false, true, false, true)
	end
end

function CloneThink( keys )
	local clone = keys.target

	--check if clone is ready to attack
	local cloneMod = clone:FindModifierByName("modifier_monkey_clone_think")
	if cloneMod then
		if cloneMod:GetStackCount() > 0 then
			cloneMod:DecrementStackCount()
			return
		end
	else
		print("something went wrong")
		return
	end

	--this should be moved to clone creation
	if clone:GetAcquisitionRange() ~= clone:GetAttackRange() then
		clone:SetAcquisitionRange(clone:GetAttackRange())
	end

	--look for a target
	clone:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	ExecuteOrderFromTable({
		UnitIndex = clone:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = clone:GetAbsOrigin(),
	})
end