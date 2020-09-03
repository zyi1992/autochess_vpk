return {
	--出场动画
	dac_animation_list = {
		n000 = {	
			--回城卷轴
			tp_effect = "effect/tp/1.vpcf",
			tp_sound = "dac.tp",
			animation_modifier = nil,
		},
		n101 = {	
			--破土而出
			tp_effect = nil,
			tp_sound = nil,
			animation_modifier = "breaksoil",
		},
		n201 = {	
			--天降神兵
			tp_effect = nil,
			tp_sound = nil,
			animation_modifier = "fall",
		},
		n202 = {	
			--MK-III机甲远行鞋
			tp_effect = "effect/animation/tk_teleport/1econ/items/tinker/boots_of_travel/teleport_end_bots.vpcf",
			tp_sound = "animation.tk_boots",
			animation_modifier = nil,
		},
		n301 = {	
			--过度生长
			tp_effect = "effect/animation/tree/1oak_01.vpcf",
			tp_sound = "animation.tree",
			animation_modifier = nil,
			end_effect = "effect/animation/tree/2_oak_01_destruction.vpcf",
		},
		n401 = {	
			--洪流浪潮
			tp_effect = "effect/animation/water/1kunkka/kunkka_spell_torrent_bubbles.vpcf",
			tp_sound = nil,
			animation_modifier = "torrent",
		},
		n402 = {
			--龙炎饼干
			tp_effect = "effect/animation/cookie/revealed_cookies.vpcf",
			tp_sound = "animation.cookie",
			animation_modifier = nil,
			end_effect = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf",
		}
	},

} 