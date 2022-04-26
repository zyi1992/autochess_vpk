modifier_elfrun = class({})

animation = ACT_DOTA_RUN

function modifier_elfrun:IsStunDebuff()
    return true
end

function modifier_elfrun:IsHidden()
    return true
end

function modifier_elfrun:IsPurgable()
    return false
end

function modifier_elfrun:RemoveOnDeath()
    return false
end

function modifier_elfrun:OnCreated(kv)
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        local speed = kv.speed or 1500
        -- if self:GetParent() ~= nil and self:GetParent():GetIdealSpeed() ~= nil then
        --     speed = self:GetParent():GetIdealSpeed()
        -- end
        if speed > 2000 then
            speed = 2000
        end
        if speed < 100 then
            speed = 100
        end

        self.vStartPosition    = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )

        self.vTargetPosition   = Vector(kv.vx,kv.vy,128)

        self.vDirection        = (self.vTargetPosition - self.vStartPosition):Normalized()
        self.flHorizontalSpeed = speed/30
        self.flDistance        = (self.vTargetPosition - self.vStartPosition):Length2D() + self.flHorizontalSpeed
        self.leap_traveled = 0
        --self:GetParent():SetForwardVector(self.vDirection)

        self.sound = kv.sound or "Courier.Footsteps"
        -- 创建开始的特效和音效
        EmitSoundOn(self.sound, self:GetParent())
        if speed > 1000 then
            play_particle("particles/items_fx/courier_speed.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent(),3)
        end
        -- self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_bounty_hunter_wind_walk",nil)

        self.animation = kv.animation or ACT_DOTA_RUN
    end
end

function modifier_elfrun:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        if _G.game_status == 1 then
            self:GetParent():SetForwardVector(Vector(0,1,0))
        end
    end
end

function modifier_elfrun:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_elfrun:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }

    return state
end

function modifier_elfrun:GetOverrideAnimation()
    return animation or ACT_DOTA_RUN
end

function modifier_elfrun:UpdateHorizontalMotion(me, dt)
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
            -- me.blink_start_p = nil
            -- me.blink_stop_count = 0
            -- play_particle("particles/dev/library/base_dust_hit_shockwave.vpcf",PATTACH_ABSORIGIN_FOLLOW,me,3)
            -- EmitSoundOn("Hero_OgreMagi.Idle.Headbutt",me)
            self:Destroy()
        end
    end
end

function modifier_elfrun:UpdateVerticalMotion(me, dt)
    -- if IsServer() then
    --     if self.flDistance > 300 then
    --         local z = math.sin(self.leap_traveled/self.flDistance*3.1415926)*2*self.flDistance/3.1415926
    --         me:SetAbsOrigin(GetGroundPosition(me:GetAbsOrigin(), me) + Vector(0,0,z/2))
    --     -- else
    --     --     self.animation = ACT_DOTA_RUN
    --     end
    -- end
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