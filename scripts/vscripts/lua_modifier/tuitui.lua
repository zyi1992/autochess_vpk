modifier_tuitui = class({})

animation = ACT_DOTA_FLAIL

function modifier_tuitui:IsStunDebuff()
    return true
end

function modifier_tuitui:IsHidden()
    return true
end

function modifier_tuitui:IsPurgable()
    return false
end

function modifier_tuitui:RemoveOnDeath()
    return false
end

function modifier_tuitui:OnCreated(kv)
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

        -- self.sound = kv.sound
        -- -- 创建开始的特效和音效
        -- if self.sound then
        --     EmitSoundOn(self.sound, self:GetParent())
        -- end

        self:GetParent().tuitui_particle = ParticleManager:CreateParticle('particles/items_fx/force_staff.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        self.animation = ACT_DOTA_FLAIL
    end
end

function modifier_tuitui:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        if GameRules:GetGameModeEntity().game_status == 1 or self:GetParent().transfer_chess == true then
            self:GetParent().transfer_chess = false
            self:GetParent():SetForwardVector(Vector(0,1,0))
        end
    end
end

function modifier_tuitui:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_tuitui:CheckState()
    local state = {
    }

    return state
end

function modifier_tuitui:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_tuitui:UpdateHorizontalMotion(me, dt)
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
            me:InterruptMotionControllers(true)
            play_particle("particles/dev/library/base_dust_hit_shockwave.vpcf",PATTACH_ABSORIGIN_FOLLOW,me,3)
            EmitSoundOn("Hero_OgreMagi.Idle.Headbutt",me)
            if me.tuitui_particle ~= nil then
                ParticleManager:DestroyParticle(me.tuitui_particle,true)
            end
            self:Destroy()
            me.is_removing = false
            me.blink_start_p = nil
            me.blink_stop_count = 0
        end
    end
end

function modifier_tuitui:UpdateVerticalMotion(me, dt)
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