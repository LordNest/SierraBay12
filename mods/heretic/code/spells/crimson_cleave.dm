/spell/targeted/equip_item/crimson_cleave
	name = "Crimson Cleave"
	desc = "A targeted spell which siphons health in a small AOE. Cleanses all wounds upon casting."
	feedback = "CC"
	charge_type = Sp_HOLDVAR
	holder_var_type = "fireloss"
	holder_var_amount = 10
	school = "conjuration"
	invocation = "Anrhydeddu Fi!"
	invocation_type = SpI_WHISPER
	spell_flags = INCLUDEUSER
	range = -1
	level_max = list(Sp_TOTAL = 1, Sp_SPEED = 0, Sp_POWER = 1)
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
	icon = 'icons/obj/weapons/melee_energy.dmi'
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"

/obj/item/spell/crimson_cleave/do_spell_effect(atom/target, mob/user)
	. = ..()
