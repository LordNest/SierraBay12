/*!
 * Tier 4 knowledge: Combat related knowledge
 */

/* /datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Grants you Space Phase, a spell that allows you to move freely through space. \
		You can only phase in and out when you are on a space or misc turf."
	gain_text = "You feel like your body can move through space as if you where dust."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 2
	research_tree_icon_frame = 6
	drafting_tier = 4
*/
/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, lungs, and any belt into an Unfathomable Curio - \
			a belt that can hold blades and items for rituals. Whilst worn it will veil you, \
			blocking one blow of incoming damage, at the cost of the veil. The veil will recharge itself out of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."

	required_atoms = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/stack/material/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "ghoul_voiceless"
	drafting_tier = 4

/datum/heretic_knowledge/spell/crimson_cleave
	name = "Crimson Cleave"
	desc = "Grants you Crimson Cleave, a targeted spell which siphons health in a small AOE. Cleanses all wounds upon casting"
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
				told me to use them regardless. Soon, he said, I would know them well."
	action_to_add = /spell/targeted/equip_item/crimson_cleave
	cost = 2
	drafting_tier = 4

/datum/heretic_knowledge/limited_amount/true_return
	name = "True Return"
	desc = "Allows you to transmute heart, lungs, and soulstone to revive one person in body, which lies upon your rune. \
			If soulstone is filled, captured soul will enter body. Else - it will be original owner of dead body."
	gain_text = "Many things can't be reverted, but once in millenia something can happen."

	required_atoms = list(
		/mob/living/carbon/human = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/organ/internal/brain = 1,
		/obj/item/device/soulstone = 1,
	)
	limit = 1
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "ghoul_voiceless"
	drafting_tier = 4

/datum/heretic_knowledge/limited_amount/true_return/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
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

/datum/heretic_knowledge/limited_amount/true_return/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
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
	make_ghoul(user, soon_to_be_ghoul)
	return TRUE

/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/true_return/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	log_and_message_admins("[key_name_admin(user)] created a voiceless dead, [key_name_admin(victim)].")
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

/datum/heretic_knowledge/rifle
	name = "Lionhunter's Rifle"
	desc = "Unleash the Lionhunter's rifle.<br>\
		The Lionhunter's Rifle is a long ranged ballistic weapon with three shots. \
		These shots function as normal, albeit weak high-caliber munitions when fired from \
		close range or at inanimate objects. You can aim the rifle at distant foes, \
		causing the shot to mark your victim with your grasp and teleport you directly to them."
	// transmute_text = "Transmute a piece of wood, hide from any animal, and a camera."
	gain_text = "I met an old man in an antique shop who wielded a very unusual weapon. \
		I could not purchase it at the time, but they showed me how they made it ages ago."
	required_atoms = list(
		/obj/item/stack/material/wood = 1,
		/obj/item/stack/material/leather = 1,
		/obj/item/device/camera = 1,
	)
	result_atoms = list(/obj/item/gun/projectile/sniper/semistrip/hex)
	cost = 2
	research_tree_icon_path = 'mods/guns/icons/obj/garand.dmi'
	research_tree_icon_state = "garand"
	drafting_tier = 2

/datum/heretic_knowledge/rifle_ammo
	name = "Lionhunter Rifle Ammunition"
	desc = "Create an extra clip of ammunition for the Lionhunter Rifle."
	// transmute_text = "Transmute 3 ballistic ammo casings (used or unused) of any caliber, including shotgun shells."
	gain_text = "The weapon came with three rough iron balls, intended to be used as ammunition. \
		They were very effective, for simple iron, but used up quickly. I soon ran out. \
		No replacement munitions worked in their stead. It was peculiar in what it wanted."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_magazine/speedloader/clip/hex)
	cost = 0
	research_tree_icon_path = 'mods/guns/icons/obj/ammo.dmi'
	research_tree_icon_state = "electrode_h"

	/// A list of calibers that the ritual will deny. Only ballistic calibers are allowed.
	var/static/list/caliber_blacklist = list(
		CALIBER_CAPS,
		CALIBER_DART,
		// CALIBER_ROCKETS,
		// CALIBER_ARROW,
		// CALIBER_HARPOON,
		// CALIBER_HOOK,
	)

/datum/heretic_knowledge/rifle_ammo/pre_research(mob/user, datum/antagonist/heretic/our_heretic)
	if(!our_heretic.get_knowledge(/datum/heretic_knowledge/rifle))
		alert(user, "You must research the Lionhunter's Rifle knowledge before you can research its ammunition.")
		return FALSE

	return TRUE

/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing
	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE
