modifier_breaksoil = class({})

animation = ACT_DOTA_FLAIL

function modifier_breaksoil:IsStunDebuff()
    return true
end

function modifier_breaksoil:IsHidden()
    return true
end

function modifier_breaksoil:IsPurgable()
    return false
end

function modifier_breaksoil:RemoveOnDeath()
    return false
end

function modifier_breaksoil:OnCreated(kv)
    if IsServer() then
        if self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        --初始化高度
        self.vStartPosition    = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent()) + Vector(0,0,-200)
        self:GetParent():SetOrigin(self.vStartPosition)

        local ppp = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_loadout.vpcf", PATTACH_WORLDORIGIN ,nil)
        ParticleManager:SetParticleControl(ppp, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(ppp, 1, self:GetParent():GetAbsOrigin())
        Timers:CreateTimer(3,function()
            if ppp ~= nil then
                ParticleManager:DestroyParticle(ppp,true)
            end
        end)
        EmitSoundOn('Hero_EarthSpirit.Magnetize.Debris',self:GetParent())

        -- play_particle("particles/econ/items/natures_prophet/natures_prophet_weapon_sufferwood/furion_teleport_end_team_sufferwood.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent(),5)
        -- local pos = keys.pos or PATTACH_ABSORIGIN_FOLLOW
        -- local pp = ParticleManager:CreateParticle("particles/econ/items/natures_prophet/natures_prophet_weapon_sufferwood/furion_teleport_end_team_sufferwood.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        -- ParticleManager:SetParticleControlEnt( pp, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true );
        -- ParticleManager:SetParticleControlEnt( pp, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true );

        -- Timers:CreateTimer(5,function()
        --     if pp ~= nil then
        --         ParticleManager:DestroyParticle(pp,true)
        --     end
        -- end)

        --目标点
        self.vTargetPosition   = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent())

    end
end

function modifier_breaksoil:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        -- self:GetParent():SetForwardVector(Vector(0,-1,0))
    end
end

function modifier_breaksoil:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_breaksoil:CheckState()
    local state = {
    }
    return state
end

function modifier_breaksoil:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_breaksoil:UpdateVerticalMotion(me, dt)
    if IsServer() then
        local curr_position = self:GetParent():GetOrigin() + Vector(0,0,10)
        me:SetAbsOrigin(curr_position)

        -- 判断是否到达了地面
        if (me:GetOrigin()-self.vTargetPosition):Length() < 20 then
            --到终点了
            me:SetAbsOrigin(self.vTargetPosition)
            me.is_moving = false
            me:InterruptMotionControllers(true)

            self:Destroy()
        end
    end
end

function play_particle(p, pos, u, d, position)
    -- if u == nil then
    --  return
    -- end
    local pp = ParticleManager:CreateParticle(p, pos, u)
    ParticleManager:SetParticleControlEnt( pp, 0, u, pos, nil, position, true );
    ParticleManager:SetParticleControlEnt( pp, 1, u, pos, nil, position, true );
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