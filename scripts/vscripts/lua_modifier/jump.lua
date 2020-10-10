modifier_jump = class({})

animation = ACT_DOTA_FLAIL

function modifier_jump:IsStunDebuff()
    return false
end

function modifier_jump:IsHidden()
    return true
end

function modifier_jump:IsPurgable()
    return false
end

function modifier_jump:RemoveOnDeath()
    return false
end

function modifier_jump:OnCreated(kv)
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        self.vStartPosition    = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )

        self.vTargetPosition   = Vector(kv.vx,kv.vy,128)

        self.vDirection        = (self.vTargetPosition - self.vStartPosition):Normalized()
        self.flHorizontalSpeed = 1000.0/30
        self.flDistance        = (self.vTargetPosition - self.vStartPosition):Length2D() + self.flHorizontalSpeed
        self.leap_traveled = 0
        --self:GetParent():SetForwardVector(self.vDirection)

        self.sound = kv.sound or "Ability.TossThrow"
        -- 创建开始的特效和音效
        EmitSoundOn(self.sound, self:GetParent())

        self.animation = kv.animation or ACT_DOTA_FLAIL
    end
end

function modifier_jump:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        if GameRules:GetGameModeEntity().game_status == 1 or self:GetParent().transfer_chess == true then
            self:GetParent().transfer_chess = false
            self:GetParent():SetForwardVector(Vector(0,1,0))

        end
    end
end

function modifier_jump:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_jump:CheckState()
    local state = {
        -- [MODIFIER_STATE_STUNNED] = true,
        -- [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }

    return state
end

function modifier_jump:GetOverrideAnimation()
    return animation or ACT_DOTA_FLAIL
end

function modifier_jump:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        -- 判断是否到达了终点
        -- if self.leap_traveled < self.flDistance then
        if (me:GetAbsOrigin()-self.vTargetPosition):Length2D() > self.flHorizontalSpeed then
            me:SetAbsOrigin(me:GetAbsOrigin() + self.vDirection * self.flHorizontalSpeed)
            self.leap_traveled = self.leap_traveled + self.flHorizontalSpeed
        else
            --到终点了
            me:SetAbsOrigin(self.vTargetPosition)
            me.is_moving = false
            RemoveAbilityAndModifier(me,'jiaoxie')
            me:InterruptMotionControllers(true)
            play_particle("particles/dev/library/base_dust_hit_shockwave.vpcf",PATTACH_ABSORIGIN_FOLLOW,me,3)
            EmitSoundOn("Hero_OgreMagi.Idle.Headbutt",me)
            self:Destroy()
            me.is_removing = false
            me.blink_start_p = nil
            me.blink_stop_count = 0
        end
    end
end

function modifier_jump:UpdateVerticalMotion(me, dt)
    if IsServer() then
        if self.flDistance > 300 then
            local z = math.sin(self.leap_traveled/self.flDistance*3.1415926)*2*self.flDistance/3.1415926
            me:SetAbsOrigin(GetGroundPosition(me:GetAbsOrigin(), me) + Vector(0,0,z/2))
        -- else
        --     self.animation = ACT_DOTA_RUN
        end
    end
end

function play_particle(p, pos, u, d)
    -- if u == nil then
    --  return
    -- end
    local pp = ParticleManager:CreateParticle(p, pos, u)
    -- Timers:CreateTimer(function()
    --  if u:IsNull() ~= false or u:IsAlive() ~= false then
    --      ParticleManager:DestroyParticle(pp,true)
    --      return
    --  end
    --  return 1
    -- end)
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