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
	result_atoms = list(/obj/item/clothing/accessory/badge/heretic_focus)
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
