modifier_toss = class({})

animation = ACT_DOTA_FLAIL

function modifier_toss:IsStunDebuff()
    return true
end

function modifier_toss:IsHidden()
    return true
end

function modifier_toss:IsPurgable()
    return false
end

function modifier_toss:RemoveOnDeath()
    return false
end

function modifier_toss:OnCreated(kv)
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        self.vStartPosition    = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
        self.vTargetPosition   = Vector(kv.vx,kv.vy,128)
        self.vDirection        = (self.vTargetPosition - self.vStartPosition):Normalized()
        self.fDistance         = (self.vTargetPosition - self.vStartPosition):Length2D()
        self.step = 0  --0~30

        -- 创建开始的特效和音效
        EmitSoundOn("Ability.TossThrow", self:GetParent())

        self.animation = kv.animation or ACT_DOTA_FLAIL
    end
end

function modifier_toss:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        if GameRules:GetGameModeEntity().game_status == 1 or self:GetParent().transfer_chess == true then
            self:GetParent().transfer_chess = false
            self:GetParent():SetForwardVector(Vector(0,1,0))
        end
    end
end

function modifier_toss:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_toss:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }

    return state
end

function modifier_toss:GetOverrideAnimation()
    return animation or ACT_DOTA_FLAIL
end

function modifier_toss:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        -- 判断是否到达了终点
        -- if self.leap_traveled < self.flDistance then
        if self.step < 30 then
            me:SetAbsOrigin(self.vStartPosition + self.vDirection*self.fDistance*(self.step/30) )
            self.step = self.step + 1
        else
            --到终点了
            me:SetAbsOrigin(self.vTargetPosition)
            me.is_moving = false
            me:InterruptMotionControllers(true)
            self:Destroy()
            me.is_removing = false
            me.blink_start_p = nil
            me.blink_stop_count = 0
        end
    end
end

function modifier_toss:UpdateVerticalMotion(me, dt)
    if IsServer() then
        local z = (1-(self.step/15-1)*(self.step/15-1))*400
        me:SetAbsOrigin(GetGroundPosition(me:GetAbsOrigin(), me) + Vector(0,0,z))
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