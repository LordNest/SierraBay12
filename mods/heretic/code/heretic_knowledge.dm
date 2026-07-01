/**
 * # Heretic Knowledge
 *
 * The datums that allow heretics to progress and learn new spells and rituals.
 *
 * Heretic Knowledge datums are not singletons - they are instantiated as they
 * are given to heretics, and deleted if the heretic antagonist is removed.
 *
 */

/datum/heretic_knowledge
	var/name = "Етого никто не должен видеть"
	var/desc = "Master ritual holder, if you see this, inform your local wizard"
	/// The abstract parent type of the knowledge, used in determine mutual exclusivity in some cases
	abstract_type = /datum/heretic_knowledge
	/// What's shown to the heretic when the knowledge is acquired
	var/gain_text
	/// Radial menu icon
	var/icon = null
	/// Result of the ritual
	var/result_atoms = list()
	/// Ritual components
	var/list/required_atoms = list()
	var/tier = null
	// Heretic path (FLESH, HUNT, RIDDLE, COSMOS, SIDE_*)
	var/path = null
	/// If set, required_atoms checks for these *exact* types and doesn't allow them to be ingredients.
	var/list/banned_required_atoms = list()
	/// Cost of knowledge in knowledge points
	var/cost = 0
	/// The priority of the knowledge. Higher priority knowledge appear higher in the ritual list.
	/// Number itself is completely arbitrary. Does not need to be set for non-ritual knowledge.
	var/priority = 0
	///If this is considered starting knowledge, TRUE if yes
	var/is_starting_knowledge = FALSE
	/// If the spell is final knowledge, disables blade breaking and removes the cap on how many blades we can make
	var/is_final_knowledge = FALSE
	/// In case we want to override the default UI icon getter and plug in our own icon instead.
	/// if research_tree_icon_path is not null, research_tree_icon_state must also be specified or things may break
	var/research_tree_icon_path
	var/research_tree_icon_state
	var/research_tree_icon_frame = 1
	var/research_tree_icon_dir = SOUTH
	/// This is used for the drafting system. By default is 0 (Meaning it won't show up in the draft), also makes it show up in the shop according to this tier
	var/drafting_tier = 0
	/// decides if it's added to the shop, only, and not drafts
	var/is_shop_only = FALSE

/// Common Rituals

/datum/heretic_knowledge/book
	name = "Codex Cicatrix"
	icon = "necronimicon"
	result_atoms = list(/obj/item/book/codex)
	required_atoms = list(
		/obj/item/book = 1,
		/obj/item/pen = 1,
		/obj/item/deck/tarot = 1
	)
	tier = HERETIC_TIER_ONE

/**
 * Called before the knowledge is researched,
 * use this for any checks that should happen before the knowledge is researched.
 * Returns TRUE if the knowledge can be researched, FALSE otherwise.
 */
/datum/heretic_knowledge/proc/pre_research(mob/user, datum/antagonist/heretic/our_heretic)
	// consider moving this check to a type instead
	if(is_final_knowledge && !our_heretic.unlimited_blades)
		var/choice = alert(user, "THIS WILL DISABLE BLADE BREAKING, Are you ready to research this? The blade cap will also be removed.", "Get Final Spell?", list("Yes", "No"))
		if(choice != "Yes")
			return FALSE
	return TRUE

/** Called when the knowledge is first researched.
 * This is only ever called once per heretic.
 *
 * Arguments
 * * user - The heretic who researched something
 * * our_heretic - The antag datum of who researched us. This should never be null.
 */
/datum/heretic_knowledge/proc/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	SHOULD_CALL_PARENT(TRUE)

	if(gain_text)
		to_chat(user, SPAN_WARNING("[gain_text]"))
	on_gain(user, our_heretic)

/**
 * Called when the knowledge is applied to a mob.
 * This can be called multiple times per heretic,
 * in the case of bodyswap shenanigans.
 *
 * Arguments
 * * user - the heretic which we're applying things to
 * * our_heretic - The antag datum of who gained us. This should never be null.
 */
/datum/heretic_knowledge/proc/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	return

/**
 * Called when the knowledge is removed from a mob,
 * either due to a heretic being de-heretic'd or bodyswap memery.
 *
 * Arguments
 * * user - the heretic which we're removing things from
 * * our_heretic - The antag datum of who is losing us. This should never be null.
 */
/datum/heretic_knowledge/proc/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	return

/**
 * Determines if a heretic can actually attempt to invoke the knowledge as a ritual.
 * By default, we can only invoke knowledge with rituals associated.
 *
 * Return TRUE to have the ritual show up in the rituals list, FALSE otherwise.
 */
/datum/heretic_knowledge/proc/can_be_invoked(datum/antagonist/heretic/invoker)
	return !!LAZYLEN(required_atoms)

/**
 * Special check for rituals.
 * Called before any of the required atoms are checked.
 *
 * If you are adding a more complex summoning,
 * or something that requires a special check
 * that parses through all the atoms,
 * you should override this.
 *
 * Arguments
 * * user - the mob doing the ritual
 * * atoms - a list of all atoms being checked in the ritual.
 * * selected_atoms - an empty list(!) instance passed in by the ritual. You can add atoms to it in this proc.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual will continue, or FALSE, if the ritual is skipped / cancelled
 */
/datum/heretic_knowledge/proc/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE

/**
 * Parses specific items into a more readble form.
 * Can be overriden by knoweldge subtypes.
 */
/datum/heretic_knowledge/proc/parse_required_item(atom/item_path, number_of_things)
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
/datum/heretic_knowledge/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result_atoms))
		return FALSE

	for(var/R in result_atoms)
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
/datum/heretic_knowledge/proc/cleanup_atoms(list/selected_atoms)
	SHOULD_CALL_PARENT(TRUE)

	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)

/**
 * A knowledge subtype that grants the heretic a certain spell.
 */
/datum/heretic_knowledge/spell
	abstract_type = /datum/heretic_knowledge/spell
	/// Spell path we add to the heretic. Type-path.
	var/datum/action/action_to_add
	/// The spell we actually created.
	var/weakref/created_action_ref

/datum/heretic_knowledge/spell/Destroy()
	QDEL_NULL(created_action_ref)
	return ..()

/datum/heretic_knowledge/spell/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	// Added spells are tracked on the body, and not the mind,
	// because we handle heretic mind transfers
	// via the antag datum (on_gain and on_lose).
	var/datum/action/created_action = created_action_ref?.resolve() || new action_to_add(user)
	created_action.Grant(user)
	created_action_ref = weakref(created_action)

/datum/heretic_knowledge/spell/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/datum/action/created_action = created_action_ref?.resolve() //datum/action/cooldown/spell
	if(created_action?.owner == user)
		created_action.Remove(user)

/**
 * A knowledge subtype for knowledge that can only
 * have a limited amount of its resulting atoms
 * created at once.
 */
/datum/heretic_knowledge/limited_amount
	abstract_type = /datum/heretic_knowledge/limited_amount
	/// The limit to how many items we can create at once.
	var/limit = 1
	/// A list of weakrefs to all items we've created.
	var/list/weakref/created_items

/datum/heretic_knowledge/limited_amount/Destroy(force)
	LAZYCLEARLIST(created_items)
	return ..()

/datum/heretic_knowledge/limited_amount/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = isheretic(user)
	if(our_heretic && our_heretic.unlimited_blades)
		if(length(result_atoms & typesof(/obj/item/melee/sickly_blade)))
			return TRUE

	for(var/weakref/ref as anything in created_items)
		var/atom/real_thing = ref.resolve()
		if(QDELETED(real_thing))
			LAZYREMOVE(created_items, ref)

	if(LAZYLEN(created_items) >= limit)
		to_chat(user, SPAN_WARNING( "ritual failed, at limit!"))
		return FALSE

	return TRUE

/datum/heretic_knowledge/limited_amount/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/result in result_atoms)
		var/atom/created_thing = new result(loc)
		LAZYADD(created_items, weakref(created_thing))
	return TRUE

/**
 * A knowledge subtype for limited_amount knowledge
 * used for base knowledge (the ones that make blades)
 * Grants your path-relevant grasp upgrade, passive and grasp mark
 *
 * A heretic can only learn one /starting type knowledge,
 * and their ascension depends on whichever they chose.
 */
/datum/heretic_knowledge/limited_amount/starting
	abstract_type = /datum/heretic_knowledge/limited_amount/starting
	limit = 2
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 5
	/// The status effect typepath we apply on people on mansus grasp.
	// var/datum/status_effect/eldritch/mark_type
	/// The status effect of our passive
	// var/datum/status_effect/heretic_passive/eldritch_passive = /datum/status_effect/heretic_passive

/datum/heretic_knowledge/limited_amount/starting/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	for(var/datum/heretic_knowledge_tree_column/column_path as anything in subtypesof(/datum/heretic_knowledge_tree_column))
		if(column_path::route != our_heretic.researched_knowledge[type][HKT_ROUTE])
			continue
		our_heretic.heretic_path = new column_path()
	if(!our_heretic.heretic_path)
		// If we don't have a path, we can't continue.
		to_chat(user, SPAN_WARNING("Oh shit, something broke, no path found!"))
		stack_trace("failed to find valid path [our_heretic.heretic_shops[HERETIC_KNOWLEDGE_TREE][type][HKT_ROUTE]] from researching [src]")
		return
	our_heretic.generate_heretic_research_tree()
	determine_drafted_knowledge(
		our_heretic.heretic_path.route,
		our_heretic.heretic_shops[HERETIC_KNOWLEDGE_TREE],
		our_heretic.heretic_shops[HERETIC_KNOWLEDGE_SHOP],
		our_heretic.heretic_shops[HERETIC_KNOWLEDGE_DRAFT],
	)
	SEND_SIGNAL(src, COMSIG_HERETIC_SHOP_SETUP)
	if(our_heretic.give_objectives)
		our_heretic.forge_primary_objectives()
		// our_heretic.owner.announce_objectives()

/**
 * A knowledge subtype lets the heretic summon a monster with the ritual.
 */
/datum/heretic_knowledge/summon
	abstract_type = /datum/heretic_knowledge/summon
	/// Typepath of a mob to summon when we finish the recipe.
	var/mob/living/mob_to_summon

/datum/heretic_knowledge/summon/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
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
/datum/heretic_knowledge/proc/summon_ritual_mob(mob/living/user, turf/loc, mob/living/mob_to_summon)
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

/// The amount of knowledge points the knowledge ritual gives on success.
#define KNOWLEDGE_RITUAL_POINTS 4

/**
 * A subtype of knowledge that generates random ritual components.
 */
/datum/heretic_knowledge/knowledge_ritual
	name = "Ritual of Knowledge"
	desc = "A randomly generated transmutation ritual that rewards knowledge points and can only be completed once."
	gain_text = "Everything can be a key to unlocking the secrets behind the Gates. I must be wary and wise."
	abstract_type = /datum/heretic_knowledge/knowledge_ritual
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 10 // A pretty important midgame ritual.
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "book_open"
	/// Whether we've done the ritual. Only doable once.
	var/was_completed = FALSE

/datum/heretic_knowledge/knowledge_ritual/New()
	. = ..()
	var/static/list/potential_organs = list(
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/lungs,
	)

	var/static/list/potential_easy_items = list(
		/obj/item/material/shard,
		/obj/item/flame/candle,
		/obj/item/book,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/device/oxycandle,
		/obj/item/device/flashlight,
		/obj/item/material/clipboard,
	)

	var/static/list/potential_uncommoner_items = list(
		/obj/item/handcuffs,
		/obj/item/melee/baton,
		/obj/item/circular_saw,
		/obj/item/scalpel,
		/obj/item/clothing/gloves/insulated,
		/obj/item/clothing/glasses/sunglasses,
	)

	required_atoms = list()
	// 1 Organ, 1 Easy, 1 Hard
	required_atoms[pick(potential_organs)] += 1
	required_atoms[pick(potential_easy_items)] += 1
	required_atoms[pick(potential_uncommoner_items)] += 1

/datum/heretic_knowledge/knowledge_ritual/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/list/requirements_string = list()

	to_chat(user, SPAN_OCCULT("The [name] requires the following:"))
	for(var/obj/item/path as anything in required_atoms)
		var/amount_needed = required_atoms[path]
		to_chat(user, SPAN_OCCULT("[amount_needed] [initial(path.name)]\s..."))
		requirements_string += "[amount_needed == 1 ? "":"[amount_needed] "][initial(path.name)]\s"

	to_chat(user, SPAN_OCCULT("Completing it will reward you [KNOWLEDGE_RITUAL_POINTS] knowledge points. You can check the knowledge in your Researched Knowledge to be reminded."))

	desc = "Allows you to transmute [english_list(requirements_string)] for [KNOWLEDGE_RITUAL_POINTS] bonus knowledge points. This can only be completed once."

/datum/heretic_knowledge/knowledge_ritual/can_be_invoked(datum/antagonist/heretic/invoker)
	return !was_completed

/datum/heretic_knowledge/knowledge_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return !was_completed

/datum/heretic_knowledge/knowledge_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = isheretic(user)
	our_heretic.adjust_knowledge_points(KNOWLEDGE_RITUAL_POINTS)
	was_completed = TRUE

	var/drain_message = list(
		"A SHIMMER... POTENTIAL... POWER.",
		"A WHISPER.",
		"COVERED AND FORGOTTEN.",
		"CURSED LAND, CURSED MAN, CURSED MIND.",
		"GREATER HEIGHTS.",
		"I AM BEING WATCHED... FROM WHERE? FROM WHAT?",
		"I AM LATE FOR MY DESTINY.",
		"LIFE IS FLEETING, BUT WHAT YET STAYS?",
		"RAIN OF BLOOD. REIGN OF BLOOD.",
		"STRENGTH... UNPARALLELED. UNNATURAL.",
		"THE GATES OF THE MANSUS IS HERE, IS OPEN.",
		"THE HIGHER I RISE, THE MORE I SEE.",
		"THE VEIL IS SHATTERED.",
		"THEIR HAND IS AT MY SIDE.",
		"THEY WALK THE WORLD. UNNOTICED.",
		"TO WALK BETWEEN PLANES."
	)

	to_chat(user, SPAN_BOLD("[name] completed!"))
	to_chat(user, SPAN_OCCULT("pick([drain_message])"))
	desc += " (Completed!)"
	log_and_message_admins("[key_name(user)] completed a [name] at [world.time].")
	// user.AddMemory(/datum/memory/heretic_knowledge_ritual)
	SEND_SIGNAL(our_heretic, COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL)
	return TRUE

#undef KNOWLEDGE_RITUAL_POINTS

/**
 * The special final tier of knowledges that unlocks ASCENSION.
 */
/datum/heretic_knowledge/ultimate
	abstract_type = /datum/heretic_knowledge/ultimate
	cost = 2
	priority = MAX_KNOWLEDGE_PRIORITY + 1 // Yes, the final ritual should be ABOVE the max priority.
	required_atoms = list(/mob/living/carbon/human = 3)
	/// The text of the ascension announcement.
	/// %NAME% is replaced with the heretic's real name,
	/// and %SPOOKY% is replaced with output from [generate_heretic_text]
	var/announcement_text
	/// The sound that's played for the ascension announcement.
	var/announcement_sound

/datum/heretic_knowledge/ultimate/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	var/total_points = 0
	for(var/datum/heretic_knowledge/knowledge as anything in our_heretic.researched_knowledge)
		var/list/cost = our_heretic.researched_knowledge[knowledge][HKT_COST]
		total_points += cost

	log_and_message_admins("[key_name(user)] gained knowledge of their final ritual. \
		They have [length(our_heretic.researched_knowledge)] knowledge nodes researched, totalling [total_points] points \
		and have sacrificed [our_heretic.total_sacrifices] people ([our_heretic.high_value_sacrifices] of which were high value)")
