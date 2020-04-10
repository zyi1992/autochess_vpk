modifier_walk = class({})

animation = ACT_DOTA_RUN

function modifier_walk:IsStunDebuff()
    return true
end

function modifier_walk:IsHidden()
    return true
end

function modifier_walk:IsPurgable()
    return false
end

function modifier_walk:RemoveOnDeath()
    return false
end

function modifier_walk:OnCreated(kv)
    if IsServer() then
        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        self.vTargetPosition   = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
        self.vStartPosition    = Entities:FindByName(nil,"center"..((self:GetParent().at_team_id or self:GetParent().team_id)-6)):GetOrigin()
        if self:GetParent().at_team_id ~= nil then
            self.vStartPosition = self.vStartPosition + Vector(0,128*6.5,0)
        else
            self.vStartPosition = self.vStartPosition + Vector(0,-128*2.5,0)
        end
        self:GetParent():SetOrigin(self.vStartPosition)

        

        self.vDirection        = (self.vTargetPosition - self.vStartPosition):Normalized()

        self:GetParent():SetForwardVector(self.vDirection)
        
        self.flHorizontalSpeed = 600.0/30
        self.flDistance        = (self.vTargetPosition - self.vStartPosition):Length2D() + self.flHorizontalSpeed
        self.leap_traveled = 0
        --self:GetParent():SetForwardVector(self.vDirection)

        -- 创建开始的特效和音效
        EmitSoundOn("Hero_Riki.Smoke_Screen", self:GetParent())
        play_particle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent(),3)
        -- self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_bounty_hunter_wind_walk",nil)

        -- local ppp = ParticleManager:CreateParticle("particles/econ/items/riki/riki_head_ti8_gold/riki_smokebomb_ti8_gold_model.vpcf", PATTACH_WORLDORIGIN ,nil)
        -- ParticleManager:SetParticleControl(ppp, 0, self:GetParent():GetAbsOrigin())
        -- Timers:CreateTimer(3,function()
        --     if ppp ~= nil then
        --         ParticleManager:DestroyParticle(ppp,true)
        --     end
        -- end)
        

        self.animation = kv.animation or ACT_DOTA_RUN
    end
end

function modifier_walk:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        play_particle("particles/units/heroes/hero_riki/riki_blink_strike_end_smoke.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent(),3)
        if self:GetParent():GetTeam() == 4 then
            self:GetParent():SetForwardVector(Vector(0,-1,0))
        else
            self:GetParent():SetForwardVector(Vector(0,1,0))
        end
    end
end

function modifier_walk:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_walk:CheckState()
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

function modifier_walk:GetOverrideAnimation()
    return animation or ACT_DOTA_RUN
end

function modifier_walk:UpdateHorizontalMotion(me, dt)
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

            self:Destroy()
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