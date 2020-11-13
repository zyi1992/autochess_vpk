function spiked_carapace_init( keys )
	keys.caster.carapaced_units = {}
end

function spiked_carapace_reflect( keys )
	-- Variables
	local caster = keys.caster
	local attacker = keys.attacker
	local damageTaken = keys.DamageTaken
	
	-- Check if it's not already been hit
	if not caster.carapaced_units[ attacker:entindex() ] and not attacker:IsMagicImmune() and not attacker:HasModifier('modifier_spiked_carapace_buff_datadriven') then
		-- attacker:SetHealth( attacker:GetHealth() - damageTaken )

		ApplyDamage({
	    	victim=attacker,
	    	attacker=caster,
	    	damage_type=DAMAGE_TYPE_PURE,
	    	damage=damageTaken
	    })
		
		keys.ability:ApplyDataDrivenModifier( caster, attacker, "modifier_spiked_carapaced_stun_datadriven", { } )
		caster:SetHealth( caster:GetHealth() + damageTaken )
		caster.carapaced_units[ attacker:entindex() ] = attacker
	end
end