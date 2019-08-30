modifier_blink = class({})

animation = ACT_DOTA_RUN

function modifier_blink:IsStunDebuff()
    return true
end

function modifier_blink:IsHidden()
    return true
end

function modifier_blink:IsPurgable()
    return false
end

function modifier_blink:RemoveOnDeath()
    return false
end

function modifier_blink:OnCreated(kv)
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

        self.sound = kv.sound or "Hero_Clinkz.WindWalk"
        -- 创建开始的特效和音效
        EmitSoundOn(self.sound, self:GetParent())
        play_particle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent(),3)
        self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_bounty_hunter_wind_walk",nil)
        

        self.animation = kv.animation or ACT_DOTA_RUN
    end
end

function modifier_blink:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_bounty_hunter_wind_walk")
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        if GameRules:GetGameModeEntity().game_status == 1 then
            self:GetParent():SetForwardVector(Vector(0,1,0))
        end
    end
end

function modifier_blink:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_blink:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVISIBLE] = true,
    }

    return state
end

function modifier_blink:GetOverrideAnimation()
    return animation or ACT_DOTA_RUN
end

function modifier_blink:UpdateHorizontalMotion(me, dt)
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
            -- play_particle("particles/dev/library/base_dust_hit_shockwave.vpcf",PATTACH_ABSORIGIN_FOLLOW,me,3)
            -- EmitSoundOn("Hero_OgreMagi.Idle.Headbutt",me)
            self:Destroy()
        end
    end
end

function modifier_blink:UpdateVerticalMotion(me, dt)
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