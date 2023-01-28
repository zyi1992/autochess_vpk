

function BlockByLinken(target)
	for slot=0,5 do
		if target:GetItemInSlot(slot)~= nil then
			local ability = target:GetItemInSlot(slot)
			local name = ability:GetAbilityName()
			if name == 'item_linkenfaqiu' and ability:IsCooldownReady() == true then
				target:RemoveModifierByName("modifier_item_sphere_target")
				ability.cd = true
				ability:StartCooldown(10)
				
				play_particle("particles/items_fx/immunity_sphere_2.vpcf",PATTACH_ABSORIGIN_FOLLOW,target,3)
				EmitSoundOn("item.linken",target)
				return true
			end
		end
	end

	return false
end
function play_particle(p, pos, u, d)
	local pp = ParticleManager:CreateParticle(p, pos, u)
	Timers:CreateTimer(d,function()
		if pp ~= nil then
			ParticleManager:DestroyParticle(pp,true)
		end
	end)
end