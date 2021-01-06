ability_acid_spray = class({})
LinkLuaModifier('modifier_acid_spray_lua_debuff', 'heroes/hero_alchemist/acid_spray', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_acid_spray_lua_aura', 'heroes/hero_alchemist/acid_spray', LUA_MODIFIER_MOTION_NONE)
function ability_acid_spray:OnSpellStart()
    local nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_alchemist/alchemist_acid_spray_cast.vpcf', PATTACH_ABSORIGIN, self:GetCaster())

    ParticleManager:ReleaseParticleIndex(nfx)
    local modifier = CreateModifierThinker(self:GetCaster(), self, 'modifier_acid_spray_lua_aura', {duration = self:GetSpecialValueFor('duration')}, self:GetCursorPosition(), self:GetCaster():GetTeam(), false)
end
function ability_acid_spray:GetAOERadius() return self:GetSpecialValueFor("radius") end
modifier_acid_spray_lua_aura = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    AllowIllusionDuplicate  = function(self) return false end,
    IsPermanent             = function(self) return true end,
    IsAura                  = function(self) return false end,
})

function modifier_acid_spray_lua_aura:OnCreated(table)
    local ability = self:GetAbility()
    self.radius = ability:GetSpecialValueFor('radius')
    if IsClient() then return end
    self.nfx = ParticleManager:CreateParticle('particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf', PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetOrigin())
    ParticleManager:SetParticleControl(self.nfx, 1, Vector(self.radius,1,self.radius))
    self:GetParent():EmitSound('Hero_Alchemist.AcidSpray')

    self:StartIntervalThink(ability:GetSpecialValueFor('tick_rate'))
end

function modifier_acid_spray_lua_aura:OnDestroy()
    if self.nfx then 
        ParticleManager:DestroyParticle(self.nfx, true)
        ParticleManager:ReleaseParticleIndex(self.nfx)
    end
end

function modifier_acid_spray_lua_aura:OnIntervalThink() 
    if IsClient() then return end
    if self:GetCaster() == nil then return end
    local all = FindUnitsInRadius(self:GetCaster():GetTeam(), 
        self:GetParent():GetAbsOrigin(), 
        nil, 
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER, 
        false)
    for _,unit in pairs(all) do
        unit:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_acid_spray_lua_debuff",{ duration = 1 })
    end
end 

modifier_acid_spray_lua_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    AllowIllusionDuplicate  = function(self) return false end, 
    DeclareFunctions        = function(self) return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end,
    GetModifierPhysicalArmorBonus  = function(self) 
        local ability = self:GetAbility()
        if ability ~= nil then
            return ability:GetSpecialValueFor('armor_reduction') * -1
        else
            return 0
        end
    end,
})

-- modifier_acid_spray_lua_debuff = class({
--     IsHidden                = function(self) return false end,
--     IsPurgable              = function(self) return true end,
--     IsPurgeException        = function(self) return false end,
--     IsDebuff                = function(self) return true end,
--     IsBuff                  = function(self) return false end,
--     RemoveOnDeath           = function(self) return true end,
--     CheckState              = function(self)
--         return {
--             [MODIFIER_STATE_SILENCED] = true,
--         }
--     end,
--     GetEffectName           = function(self) return "particles/generic_gameplay/generic_silenced.vpcf" end,
--     GetEffectAttachType     = function(self) return PATTACH_OVERHEAD_FOLLOW end,
-- })