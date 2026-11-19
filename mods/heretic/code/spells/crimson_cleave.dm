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
	name = "\improper Reddish Glow"
	icon = 'mods/heretic/icons/actions_ecult.dmi'
	icon_state = "hand"
	range = 8

/obj/item/spell/crimson_cleave/do_spell_effect(atom/target, mob/user)
	. = ..()
	var/stolen_blood
	for(var/mob/living/carbon/human/victim in range(1, target))
		if(victim != user)
			if(ishuman(victim))
				if(victim.isSynthetic())
					if(victim.isFBP())
						var/obj/item/organ/internal/mmi_holder/mmi = victim.internal_organs_by_name[BP_BRAIN]
						mmi.die()
					else
						continue
				else
					victim.remove_blood_simple(40)
					victim.take_organ_damage(15, 0)
					stolen_blood += 40
	var/mob/living/carbon/human/U = user
	U.regenerate_blood(stolen_blood / 2)
	// Subject to change in case of imbalance
	U.ling_heal_single_organ()
