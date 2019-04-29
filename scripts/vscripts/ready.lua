modifier_ready = class({})

function modifier_ready:IsStunDebuff()
    return true
end

function modifier_ready:IsHidden()
    return true
end

function modifier_ready:IsPurgable()
    return false
end

function modifier_ready:RemoveOnDeath()
    return false
end

function modifier_ready:OnCreated(kv)
	return
end

function modifier_ready:OnDestroy()
	return
end

function modifier_ready:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_ready:GetOverrideAnimation()
    return ACT_DOTA_RUN
end
