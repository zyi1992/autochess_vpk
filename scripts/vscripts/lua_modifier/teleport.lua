modifier_teleport = class({})

function modifier_teleport:IsStunDebuff()
    return true
end

function modifier_teleport:IsHidden()
    return true
end

function modifier_teleport:IsPurgable()
    return false
end

function modifier_teleport:RemoveOnDeath()
    return false
end

function modifier_teleport:OnCreated(kv)
	return
end

function modifier_teleport:OnDestroy()
	return
end

function modifier_teleport:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_teleport:GetOverrideAnimation()
    return ACT_DOTA_TELEPORT
end
