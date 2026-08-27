/spell/targeted/equip_item/flesh_surgery
	name = "Crimson Cleave"
	desc = "A targeted spell which siphons health in a small AOE. Cleanses all wounds upon casting."
	feedback = "FS"
	charge_type = Sp_RECHARGE
	school = "transmutation"
	invocation = "none"
	invocation_type = SpI_NONE
	spell_flags = INCLUDEUSER
	range = -1
	level_max = list(Sp_TOTAL = 1, Sp_SPEED = 0, Sp_POWER = 1)
	duration = 300 //30 seconds
	max_targets = 1
	equipped_summons = list("active hand" = /obj/item/spell/flesh_surgery)
	delete_old = 0

	hud_state = "gen_immolate"


/spell/targeted/equip_item/flesh_surgery/summon_item(new_type)
	var/obj/item/C = new new_type
	return C

/spell/targeted/equip_item/flesh_surgery/check_valid_targets(list/targets)
	return TRUE

/obj/item/spell/flesh_surgery
	icon = 'mods/heretic/icons/actions_ecult.dmi'
	icon_state = "mad_touch"


/obj/item/spell/flesh_surgery/do_spell_effect(atom/target, mob/user)
	. = ..()
