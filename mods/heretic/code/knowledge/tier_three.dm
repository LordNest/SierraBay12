/*!
 * Tier 3 knowledge: Summons
 */

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = "Allows you to transmute five sheets of glass, any suit, and a pair of lungs to create a Maid in the Mirror. \
			Maid in the Mirrors are decent combatants that can become incorporeal by phasing in and out of the mirror realm, serving as powerful scouts and ambushers. \
			Their attacks also apply a stack of void chill."
	gain_text = "Within each reflection, lies a gateway into an unimaginable world of colors never seen and \
		people never met. The ascent is glass, and the walls are knives. Each step is blood, if you do not have a guide."

	required_atoms = list(
		/obj/item/stack/material/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/internal/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/simple_animal/heretic_summon/maid_in_the_mirror
	drafting_tier = 3

/datum/heretic_knowledge/vermin_ball
	name = "Ball of Vermins"
	desc = "Allows you to transmute five sheets of glass, any suit, and a pair of lungs to create a Maid in the Mirror. \
			Maid in the Mirrors are decent combatants that can become incorporeal by phasing in and out of the mirror realm, serving as powerful scouts and ambushers. \
			Their attacks also apply a stack of void chill."
	gain_text = "Within each reflection, lies a gateway into an unimaginable world of colors never seen and \
		people never met. The ascent is glass, and the walls are knives. Each step is blood, if you do not have a guide."

	required_atoms = list(
		/obj/decal/cleanable/vomit = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/internal/liver = 1,
	)
	cost = 2

	result_atoms = list(/obj/item/melee/rune_carver)
	drafting_tier = 3

/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Ritual"
	desc = "Enchant a corpse into a Shattered Risen.<br>\
		Shattered Risen are strong ghouls that have 125 health, but cannot hold items, \
		instead having two brutal weapons for hands. You can only create one at a time."
	// transmute_text = "Transmute a corpse with a soul, a pair of latex or nitrile gloves."
	gain_text = "I witnessed a cold, rending force drag this corpse back to near-life. \
		When it moves, it crunches like broken glass. Its hands are no longer recognizable as human - \
		each clenched fist contains a brutal nest of sharp bone-shards instead."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/latex = 1,
	)
	limit = 1
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"
	drafting_tier = 3

/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(MUTATION_HUSK in body.mutations)
			to_chat(user, SPAN_OCCULT("[body] is not in a valid state to be made into a ghoul."))
			continue

		// We'll select any valid bodies here. If they're clientless, we'll give them a new one.
		selected_atoms += body
		return TRUE

	loc.visible_message(user, "ritual failed, no valid body!")
	return FALSE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.visible_message(user, "ritual failed, no valid body!")
		return FALSE


	for(var/mob/observer/G in GLOB.dead_mobs)
		if(G.mind && G.mind.current == soon_to_be_ghoul && G.client)
			to_chat(G, SPAN_NOTICE("<font size = 3><b>Your body has been revived, <b>Re-Enter Corpse</b> to return to it.</b></font>"))
			break

	// addtimer(new Callback(src,PROC_REF(check_for_revoke),targets), 20 SECONDS)
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		log_and_message_admins("[user] is creating a ghoul of a body with no player.")
		// loc.visible_message(user, "ritual failed, no ghost within the body!")
		// return FALSE
		var/datum/ghosttrap/T = get_ghost_trap("heretic ghoul")
		T.request_player(src, "A heretic's ghoul needs player.")
		if(!soon_to_be_ghoul.key)
			loc.visible_message(user, "ritual failed, no ghosts!")
			return FALSE
		else
			log_and_message_admins("[key_name_admin(soon_to_be_ghoul.key)] has taken control of ([key_name_admin(soon_to_be_ghoul)] to replace an AFK player.")

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE

/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	log_and_message_admins("[key_name_admin(user)] created a shattered risen, [key_name_admin(victim)].")
	if(victim.is_species(SPECIES_IPC) || victim.is_species(SPECIES_ADHERENT) || BP_IS_ROBOTIC(victim.organs_by_name[BP_CHEST]))
		to_chat(victim, SPAN_DANGER("Suddenly you found yourself in new world full of PAIN!"))
		victim.set_species(SPECIES_MOTH) // TO DO: KILL MOTH
		alert(victim, "Ты теперь подчинен воле [user], служи ему слепо и верно, пока он не скажет обратного.", "Ты был порабощен")
		GLOB.thralls.add_antagonist(victim.mind, new_controller = user)
		return TRUE
	else
		victim.basic_revival()
		victim.Drain()
		alert(victim, "Ты теперь подчинен воле [user], служи ему слепо и верно, пока он не скажет обратного.", "Ты был порабощен")
		GLOB.thralls.add_antagonist(victim.mind, new_controller = user)
		return TRUE

// /// Callback for the ghoul status effect - what effects are applied to the ghoul.
// /datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
// 	LAZYADD(created_items, WEAKREF(risen))
// 	risen.AddComponent(/datum/component/mutant_hands, mutant_hand_path = /obj/item/mutant_hand/shattered_risen)

// /// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
// /datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
// 	LAZYREMOVE(created_items, WEAKREF(risen))
// 	qdel(risen.GetComponent(/datum/component/mutant_hands))

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "bone-shards"
	desc = "What once appeared to be a normal human fist, now holds a mauled nest of sharp bone-shards."
	color = "#001aff"
	force = 16

/datum/heretic_knowledge/mad_mask
	name = "Mask of Madness"
	desc = "Create a Mask of Madness.<br>\
		The mask instills fear into heathens who witness it, causing stamina damage, hallucinations, and insanity.<br>\
		It can also be forced onto a heathen, to make them unable to take it off..."
	// transmute_text = "Transmute any mask, four lit candles, a stun baton, and a liver."
	gain_text = "The Watch wore strange garb on duty. It allowed them to walk the city, seemingly unnoticed by the masses."
	required_atoms = list(
		//obj/item/organ/liver = 1,
		//obj/item/melee/baton/security = 1,  // Technically means a cattleprod is valid
		//obj/item/clothing/mask = 1,
		//obj/item/flashlight/flare/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 2
	research_tree_icon_path = 'mods/tajara/icons/obj_accessories.dmi'
	research_tree_icon_state = "eldritch_necklace"
	drafting_tier = 3

//datum/heretic_knowledge/mad_mask/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
//	. = ..()
//	for(var/obj/item/flashlight/flare/candle/candle in atoms)
//		if(!candle.light_on)
//			atoms -= candle

//datum/heretic_knowledge/mad_mask/prepare_atom_for_ritual_test(atom/what)
//	. = ..()
//	if(istype(what, /obj/item/flashlight/flare/candle))
//		what.set_light_on(TRUE)
