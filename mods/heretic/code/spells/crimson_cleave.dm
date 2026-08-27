/spell/targeted/equip_item/crimson_cleave
	name = "Crimson Cleave"
	desc = "A targeted spell which siphons health in a small AOE. Cleanses all wounds upon casting."
	feedback = "CC"
	charge_type = Sp_RECHARGE
	school = "transmutation"
	invocation = "G'v H'h'th!"
	invocation_type = SpI_WHISPER
	spell_flags = INCLUDEUSER | NEEDSFOCUS
	range = -1
	duration = 300 //30 seconds
	max_targets = 1
	equipped_summons = list("active hand" = /obj/item/spell/crimson_cleave)
	delete_old = 0

	hud_state = "gen_immolate"


/spell/targeted/equip_item/crimson_cleave/summon_item(new_type)
	var/obj/item/C = new new_type
	return C

/spell/targeted/equip_item/crimson_cleave/check_valid_targets(list/targets)
	return TRUE

/obj/item/spell/crimson_cleave
	icon = 'mods/heretic/icons/actions_ecult.dmi'
	icon_state = "hand"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."

/obj/item/spell/crimson_cleave/do_spell_effect(atom/target, mob/user)
	. = ..()
