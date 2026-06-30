// Heretic starting knowledge.

/// Global list of all heretic knowledge that have is_starting_knowledge = TRUE. List of PATHS.
GLOBAL_LIST_AS(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.is_starting_knowledge) == TRUE)
			. += knowledge

/*
 * The base heretic knowledge. Grants the Mansus Grasp spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey into the Mansus. \
		Grants you the Mansus Grasp, a powerful and upgradable \
		disabling spell that can be cast regardless of having a focus."
	// action_to_add = /datum/action/cooldown/spell/touch/mansus_grasp
	cost = 0
	is_starting_knowledge = TRUE

// Heretics can enhance their fishing rods to fish better - fishing content.
// Lasts until successfully fishing something up.
/datum/heretic_knowledge/spell/basic/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	..()
	// RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Grants you a Living Heart, allowing you to track sacrifice targets. \
		Should you lose your heart, you can transmute a poppy and a pool of blood \
		to awaken your heart into a Living Heart. If your heart is Cybernetic, \
		you will be unable to reawaken it."
	required_atoms = list(
		/obj/decal/cleanable/blood = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "living_heart"
	research_tree_icon_frame = 1

/datum/heretic_knowledge/living_heart/on_research(mob/living/carbon/human/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/obj/item/organ/internal/where_to_put_our_heart = user.get_organ(our_heretic.living_heart_organ_slot)
	// Our heart slot is not valid to put a heart
	if(!is_valid_heart(where_to_put_our_heart))
		where_to_put_our_heart = null

	// If a heretic is made from a species without a heart, we need to find a backup.
	if(!where_to_put_our_heart)
		var/static/list/backup_organs = list(
			ORGAN_SLOT_LUNGS = /obj/item/organ/internal/lungs,
			ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver,
			ORGAN_SLOT_STOMACH = /obj/item/organ/internal/stomach,
		)

		for(var/backup_slot in backup_organs)
			var/obj/item/organ/internal/look_for_backup = user.get_organ(backup_slot)
			// This backup slot is not a valid slot to put a heart
			if(!is_valid_heart(look_for_backup))
				continue

			// We found a replacement place to put our heart
			where_to_put_our_heart = look_for_backup
			our_heretic.living_heart_organ_slot = backup_slot
			to_chat(user, SPAN_BOLD("As your species does not have a heart, your Living Heart is located in your [look_for_backup.name]."))
			break

	if(where_to_put_our_heart)
		where_to_put_our_heart.AddComponent(/datum/component/living_heart)
		desc = "Grants you a Living Heart, tied to your [where_to_put_our_heart.name], allowing you to track sacrifice targets. \
			Should you lose your [where_to_put_our_heart.name], you can transmute a poppy and a pool of blood \
			to awaken your [where_to_put_our_heart.name] into a Living Heart. \
			Cybernetic [where_to_put_our_heart.name]\s will block the ritual!"

	else
		to_chat(user, SPAN_BOLD("You don't have a heart, or any chest organs for that matter. You didn't get a Living Heart because of it."))

/datum/heretic_knowledge/living_heart/on_lose(mob/living/carbon/human/user, datum/antagonist/heretic/our_heretic)
	var/obj/item/organ/internal/our_living_heart = user.get_organ(our_heretic.living_heart_organ_slot)
	if(our_living_heart)
		qdel(our_living_heart.GetComponent(/datum/component/living_heart))

// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.has_living_heart() == HERETIC_HAS_LIVING_HEART)
		return FALSE
	return TRUE

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/carbon/human/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = isheretic(user)
	var/obj/item/organ/internal/our_living_heart = user.get_organ(our_heretic.living_heart_organ_slot)
	// No heart, nothing to give living heart to
	if(QDELETED(our_living_heart))
		to_chat(user, SPAN_WARNING("ritual failed, no [our_heretic.living_heart_organ_slot]!"))
		return FALSE

	// For sanity's sake, check if they've got a living heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(our_living_heart.is_living_heart)
		to_chat(user, SPAN_WARNING("ritual failed, already have a living heart!"))
		return FALSE

	// By this point they are making a new heart
	// If their current heart is organic / not synthetic, we can continue the ritual as normal
	if(is_valid_heart(our_living_heart))
		return TRUE

	to_chat(user, SPAN_WARNING("ritual failed, [our_heretic.living_heart_organ_slot] can't be awakened!")) // "heart can't be awakened!"
	return FALSE

/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/carbon/human/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = isheretic(user)
	var/obj/item/organ/internal/our_new_heart = user.get_organ(our_heretic.living_heart_organ_slot)
	// Don't delete our shiny new heart
	selected_atoms -= our_new_heart
	// Make it the living heart
	our_new_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, SPAN_WARNING("You feel your [our_new_heart.name] begin pulse faster and faster as it awakens!"))
	// playsound(user, 'sound/effects/magic/demon_consume.ogg', 50, TRUE)
	return TRUE

/// Checks if the passed heart is a valid heart to become a living heart
/datum/heretic_knowledge/living_heart/proc/is_valid_heart(obj/item/organ/internal/new_heart)
	if(QDELETED(new_heart))
		return FALSE
	if(BP_IS_ROBOTIC(new_heart))
		return FALSE

	return TRUE

/**
 * Allows the heretic to craft a spell focus.
 * They require a focus to cast advanced spells.
 */
/datum/heretic_knowledge/amber_focus
	name = "Amber Focus"
	desc = "Allows you to transmute a sheet of glass and a pair of eyes to create an Amber Focus. \
		A focus must be worn in order to cast more advanced spells."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/material/glass = 1,
	)
	// result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Not as important as making a heart or sacrificing, but important enough.
	is_starting_knowledge = TRUE
	// research_tree_icon_path = 'icons/obj/clothing/neck.dmi'
	research_tree_icon_state = "eldritch_necklace"

/datum/heretic_knowledge/spell/cloak_of_shadows
	name = "Cloak of Shadow"
	desc = "Grants you the spell Cloak of Shadow. This spell will completely conceal your identity in a purple smoke \
		for three minutes, assisting you in keeping secrecy. Requires a focus to cast."
	// action_to_add = /datum/action/cooldown/spell/shadow_cloak
	cost = 0
	is_starting_knowledge = TRUE

/datum/heretic_knowledge/feast_of_owls
	name = "Feast of Owls"
	desc = "Allows you to undergo a ritual that gives you 5 knowledge points but locks you out of ascension. This can only be done once and cannot be reverted."
	gain_text = "Under the soft glow of unreason there is a beast that stalks the night. I shall bring it forth and let it enter my presence. It will feast upon my amibitions and leave knowledge in its wake."
	is_starting_knowledge = TRUE
	required_atoms = list()
	// research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "god_transmit"
	/// amount of research points granted
	var/reward = 5

/datum/heretic_knowledge/feast_of_owls/can_be_invoked(datum/antagonist/heretic/invoker)
	return !invoker.feast_of_owls

/datum/heretic_knowledge/feast_of_owls/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/alert = alert(user,"Do you really want to forsake your ascension? This action cannot be reverted.", "Feast of Owls", list("Yes I'm sure", "No"), 30 SECONDS)
	if(alert != "Yes I'm sure" || QDELETED(user) || QDELETED(src) || get_dist(user, loc) > 2)
		return FALSE
	var/datum/antagonist/heretic/heretic_datum = isheretic(user)
	if(QDELETED(heretic_datum) || heretic_datum.feast_of_owls)
		return FALSE

	. = TRUE

	heretic_datum.feast_of_owls = TRUE
	user.playsound_local(get_turf(user), 'mods/heretic/sound/heretic_gain_intense.ogg', 100, FALSE)
	for(var/i in 1 to reward)
		user.emote("scream")
		playsound(loc, 'sound/items/eatfood.ogg', 100, TRUE)
		heretic_datum.adjust_knowledge_points(1)

		to_chat(user, SPAN_DANGER("You feel something invisible tearing away at your very essence!"))
		user.do_jitter()
		sleep(1 SECONDS)
		if(QDELETED(user) || QDELETED(heretic_datum))
			return FALSE

	to_chat(user, SPAN_DANGER("Your ambition is ravaged, but something powerful remains in its wake..."))
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
	to_chat(user, SPAN_OCCULT("[pick(drain_message)]"))
	return .
