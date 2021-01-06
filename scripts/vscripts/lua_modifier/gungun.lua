modifier_gungun = class({})

animation = ACT_DOTA_CAST_ABILITY_4

function modifier_gungun:IsStunDebuff()
    return false
end

function modifier_gungun:IsHidden()
    return true
end

function modifier_gungun:IsPurgable()
    return false
end

function modifier_gungun:RemoveOnDeath()
    return false
end

function modifier_gungun:OnCreated(kv)
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
            return
        end

        local speed = 1000

        self.vStartPosition    = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
        self.vTargetPosition   = Vector(kv.vx,kv.vy,128)

        self.vDirection        = (self.vTargetPosition - self.vStartPosition):Normalized()
        self.flHorizontalSpeed = speed/30
        self.flDistance        = (self.vTargetPosition - self.vStartPosition):Length2D() + self.flHorizontalSpeed
        self.leap_traveled = 0
        --self:GetParent():SetForwardVector(self.vDirection)

        -- self.sound = kv.sound or "Courier.Footsteps"
        -- -- 创建开始的特效和音效
        -- EmitSoundOn(self.sound, self:GetParent())

        self:GetParent().gungun_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        self.animation = ACT_DOTA_CAST_ABILITY_2
        -- self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2)
    end
end

function modifier_gungun:OnDestroy()
    if IsServer() then
        -- self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
    end
end

function modifier_gungun:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_gungun:CheckState()
    local state = {
        -- [MODIFIER_STATE_STUNNED] = true,
        -- [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }

    return state
end

function modifier_gungun:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function modifier_gungun:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        -- 判断是否到达了终点
        -- if self.leap_traveled < self.flDistance then
        if (me:GetAbsOrigin()-self.vTargetPosition):Length2D() > self.flHorizontalSpeed then
            --没到终点
            me:SetAbsOrigin(me:GetAbsOrigin() + self.vDirection * self.flHorizontalSpeed)
            self.leap_traveled = self.leap_traveled + self.flHorizontalSpeed
        else
            --到终点了
            me:SetAbsOrigin(self.vTargetPosition)
            me.is_moving = false
            me:InterruptMotionControllers(true)
            me.blink_start_p = nil
            me.blink_stop_count = 0
            RemoveAbilityAndModifier(me,'jiaoxie')
            if me.gungun_particle ~= nil then
                ParticleManager:DestroyParticle(me.gungun_particle,true)
            end
            -- play_particle("particles/dev/library/base_dust_hit_shockwave.vpcf",PATTACH_ABSORIGIN_FOLLOW,me,3)
            -- EmitSoundOn("Hero_OgreMagi.Idle.Headbutt",me)
            self:Destroy()
        end
    end
end

function play_particle(p, pos, u, d)
    local pp = ParticleManager:CreateParticle(p, pos, u)

    Timers:CreateTimer(d,function()
        if pp ~= nil then
            ParticleManager:DestroyParticle(pp,true)
        end
    end)
end
function RemoveAbilityAndModifier(u,a)
    if u == nil or u:IsNull() == true then
        return
    end
    if u:FindAbilityByName(a) ~= nil then
        u:RemoveAbility(a)
        u:RemoveModifierByName('modifier_'..a)
    end
end
function prt(t)
    GameRules:SendCustomMessage(''..t,0,0)
end