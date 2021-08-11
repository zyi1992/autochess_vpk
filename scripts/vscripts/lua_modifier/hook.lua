modifier_hook = class({})

animation = ACT_DOTA_FLAIL

function modifier_hook:IsStunDebuff()
    return true
end

function modifier_hook:IsHidden()
    return true
end

function modifier_hook:IsPurgable()
    return false
end

function modifier_hook:RemoveOnDeath()
    return false
end

function modifier_hook:OnCreated(kv)
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        self.vStartPosition    = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )

        self.vTargetPosition   = Vector(kv.vx,kv.vy,128)

        self.vDirection        = (self.vTargetPosition - self.vStartPosition):Normalized()
        self.flHorizontalSpeed = 1600.0/30
        self.flDistance        = (self.vTargetPosition - self.vStartPosition):Length2D() + self.flHorizontalSpeed
        self.leap_traveled = 0
        --self:GetParent():SetForwardVector(self.vDirection)

        -- self.sound = kv.sound
        -- -- 创建开始的特效和音效
        -- if self.sound then
        --     EmitSoundOn(self.sound, self:GetParent())
        -- end

        -- self:GetParent().tuitui_particle = ParticleManager:CreateParticle('particles/items_fx/force_staff.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        self.animation = ACT_DOTA_FLAIL
    end
end

function modifier_hook:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        self:GetParent().is_moving = false
        self:GetParent().is_removing = false
        self:GetParent().blink_start_p = nil
        self:GetParent().blink_stop_count = 0
        if self:GetParent().hook_cb ~= nil then
            self:GetParent().hook_cb(self:GetParent().hook_pudge)
        end
    end
end

function modifier_hook:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_hook:CheckState()
    local state = {
    }

    return state
end

function modifier_hook:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_hook:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        -- 判断是否到达了终点
        -- if self.leap_traveled < self.flDistance then
        if (me:GetAbsOrigin()-self.vTargetPosition):Length2D() > self.flHorizontalSpeed then
            me:SetAbsOrigin(me:GetAbsOrigin() + self.vDirection * self.flHorizontalSpeed)
            self.leap_traveled = self.leap_traveled + self.flHorizontalSpeed
        else
            --到终点了
            me:SetAbsOrigin(self.vTargetPosition)
            me:InterruptMotionControllers(true)
            self:Destroy()
        end
    end
end

function modifier_hook:UpdateVerticalMotion(me, dt)
    if IsServer() then
        if self.flDistance > 300 then
            -- local z = math.sin(self.leap_traveled/self.flDistance*3.1415926)*2*self.flDistance/3.1415926
            me:SetAbsOrigin(GetGroundPosition(me:GetAbsOrigin(), me) )
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