/// Базовая ритуальная часть

/datum/heretic_ritual
	var/name = "Етого никто не должен видеть"
	var/desc = "Master ritual holder, if you see this, inform your local wizard"
	/// Radial menu icon
	var/icon = null
	/// Result of the ritual
	var/result = list()
	/// Ritual components
	var/list/components = list()

	var/tier = null
	// Heretic path (FLESH, HUNT, RIDDLE, COSMOS, SIDE_*)
	var/path = null
	/// If set, required_atoms checks for these *exact* types and doesn't allow them to be ingredients.
	var/list/banned_components = list()

/// Common Rituals
/datum/heretic_ritual/sacrifice
	name = "Sacrifice"
	desc = "Place your victim on the rune and strike them with your knife in order to feed on negative energies of ritual"
	icon = "manequin"
	result = null
	components = list()
	tier = HERETIC_TIER_ONE

/datum/heretic_ritual/ascend
	name = "Ascendance master ritual"
	icon = "manequin"
	result = null
	components = list()
	tier = HERETIC_TIER_FOUR

/datum/heretic_ritual/book
	name = "Codex Cicatrix"
	icon = "necronimicon"
	result = list(/obj/item/book/codex)
	components = list(
		/obj/item/book = 1,
		/obj/item/pen = 1,
		/obj/item/deck/tarot = 1
	)
	tier = HERETIC_TIER_ONE

/**
 * Parses specific items into a more readble form.
 * Can be overriden by knoweldge subtypes.
 */
/datum/heretic_ritual/proc/parse_required_item(atom/item_path, number_of_things)
	// If we need a human, there is a high likelihood we actually need a (dead) body
	if(ispath(item_path, /mob/living/carbon/human))
		return "bod[number_of_things > 1 ? "ies" : "y"]"
	if(ispath(item_path, /mob/living))
		return "carcass[number_of_things > 1 ? "es" : ""] of any kind"
	return "[initial(item_path.name)]\s"

/**
 * Called whenever the knowledge's associated ritual is completed successfully.
 *
 * Creates atoms from types in result_atoms.
 * Override this if you want something else to happen.
 * This CAN sleep, such as for summoning rituals which poll for ghosts.
 *
 * Arguments
 * * user - the mob who did the ritual
 * * selected_atoms - an list of atoms chosen as a part of this ritual.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual should cleanup afterwards, or FALSE, to avoid calling cleanup after.
 */
/datum/heretic_ritual/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result))
		return FALSE

	for(var/R in result)
		var/atom/result_item = new R(loc)
		if(isitem(result_item))
			message_admins("Еретик [user] успешно призвал [result_item] в [loc]")
	return TRUE

/**
 * Called after on_finished_recipe returns TRUE
 * and a ritual was successfully completed.
 *
 * Goes through and cleans up (deletes)
 * all atoms in the selected_atoms list.
 *
 * Remove atoms from the selected_atoms
 * (either in this proc or in on_finished_recipe)
 * to NOT have certain atoms deleted on cleanup.
 *
 * Arguments
 * * selected_atoms - a list of all atoms we intend on destroying.
 */
/datum/heretic_ritual/proc/cleanup_atoms(list/selected_atoms)
	SHOULD_CALL_PARENT(TRUE)

	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)



/**
 * A knowledge subtype lets the heretic summon a monster with the ritual.
 */
/datum/heretic_ritual/summon
	abstract_type = /datum/heretic_ritual/summon
	/// Typepath of a mob to summon when we finish the recipe.
	var/mob/living/mob_to_summon

/datum/heretic_ritual/summon/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	return summon_ritual_mob(user, loc, mob_to_summon)

// ===========================================================================
// Ghosttrap Datum - Bay12 strikes back without heretic_monsters as antag type
// ===========================================================================

/datum/ghosttrap/heretic_summon
	object = "heretic summon"
	ban_checks = list("Animal")
	ghost_trap_message = "They are now summoned to serve the heretic."
	ghost_trap_role = "Heretic Summon"
	can_set_own_name = FALSE

/datum/ghosttrap/heretic_summon/welcome_candidate(mob/target)
	to_chat(target, SPAN_BOLD(FONT_LARGE("You have been assigned to defend this location.")))
	to_chat(target, SPAN_BOLD("Attack any intruders on sight. You do not remember your past life."))

/**
 * Creates the ritual mob and grabs a ghost for it
 *
 * * user - the mob doing the summoning
 * * loc - where the summon is happening
 * * mob_to_summon - either a mob instance or a mob typepath
 */
/datum/heretic_ritual/proc/summon_ritual_mob(mob/living/user, turf/loc, mob/living/mob_to_summon)
	set waitfor = FALSE
	var/mob/living/summoned
	if(isliving(mob_to_summon))
		summoned = mob_to_summon
	else
		summoned = new mob_to_summon(loc)
	summoned.ai_holder.stance = STANCE_SLEEP
	// Fade in the summon while the ghost poll is ongoing.
	// Also don't let them mess with the summon while waiting
	summoned.alpha = 0
	summoned.status_flags = FLAGS_OFF
	animate(summoned, 10 SECONDS, alpha = 155)

	log_and_message_admins("A [summoned.name] is being summoned.", user, loc )
	sleep(10 SECONDS)
	if(isnull(summoned.mind))
		to_chat(user, SPAN_WARNING("ritual failed, no ghosts!"))
		animate(summoned, 0.5 SECONDS, alpha = 0)
		QDEL_IN(summoned, 0.6 SECONDS)
		return FALSE

	// Ok let's make them an interactable mob now, since we got a ghost
	summoned.alpha = 255
	summoned.ai_holder.stance = STANCE_IDLE

	to_chat(summoned, SPAN_BOLD("You are a [ishuman(summoned) ? "shambling corpse returned":"horrible creation brought"] to this plane through the Gates of the Mansus."))
	to_chat(summoned, SPAN_NOTICE("Your master is [user]. Assist them to all ends."))

	log_and_message_admins("[summoned.name], controlled by [summoned.last_ckey] was created.", user, loc )

	return TRUE
