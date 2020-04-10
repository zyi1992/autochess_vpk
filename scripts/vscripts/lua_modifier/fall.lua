modifier_fall = class({})

animation = ACT_DOTA_FLAIL

function modifier_fall:IsStunDebuff()
    return true
end

function modifier_fall:IsHidden()
    return true
end

function modifier_fall:IsPurgable()
    return false
end

function modifier_fall:RemoveOnDeath()
    return false
end

function modifier_fall:OnCreated(kv)
    if IsServer() then
        if self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        --初始化高度
        self.vStartPosition    = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent()) + Vector(0,0,1000)
        self:GetParent():SetOrigin(self.vStartPosition)

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

function modifier_fall:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        -- self:GetParent():SetForwardVector(Vector(0,-1,0))
    end
end

function modifier_fall:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

function modifier_fall:CheckState()
    local state = {
    }
    return state
end

function modifier_fall:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_fall:UpdateVerticalMotion(me, dt)
    if IsServer() then
        local curr_position = self:GetParent():GetOrigin() + Vector(0,0,-60)
        me:SetAbsOrigin(curr_position)

        -- 判断是否到达了地面
        if (me:GetOrigin()-self.vTargetPosition):Length() < 30 then
            --到终点了
            me:SetAbsOrigin(self.vTargetPosition)
            me.is_moving = false
            me:InterruptMotionControllers(true)
            play_particle("particles/dev/library/base_dust_hit_shockwave.vpcf",PATTACH_ABSORIGIN_FOLLOW,me,3)
            EmitSoundOn("Hero_OgreMagi.Idle.Headbutt",me)

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