// Full Metal Alchemist, how are you?
// Mostly TG copypaste, so original comments left unchanged

/datum/power/heretic/circle
	name = "Draw Circle"
	desc = "Prepare alchemy circle for ritual perfomance."
	ability_icon_state = "mark"
	knowledgecost = 0
	make_hud_button = 1
	verbpath = /mob/proc/alchemy_rune

/mob/proc/alchemy_rune()
	set category = "Heretic"
	set name = "Draw Circle"
	set desc = "Prepare alchemy circle for ritual perfomance"

	make_circle(/obj/rune/alchemy, cost = 0)

/mob/proc/make_circle(rune, cost = 0)

	var/has_codex = !!IsHolding(/obj/item/book/codex)
	var/has_robes = 0

	if(istype(get_equipped_item(slot_head), /obj/item/clothing/head/culthood) && istype(get_equipped_item(slot_wear_suit), /obj/item/clothing/suit/cultrobes) && istype(get_equipped_item(slot_shoes), /obj/item/clothing/shoes/cult))
		has_robes = 1
	var/turf/T = get_turf(src)
	if(T.holy)
		to_chat(src, SPAN_WARNING("This place is blessed, you may not draw runes on it - defile it first."))
		return
	if(!istype(T, /turf/simulated))
		to_chat(src, SPAN_WARNING("You need more space to draw a rune here."))
		return
	if(locate(/obj/rune) in T)
		to_chat(src, SPAN_WARNING("There's already a rune here.")) // Don't cross the runes
		return
	var/self
	var/timer
	if(has_codex)
		if(has_robes)
			self = "Feeling empowered in your robes, you slice open your finger and start drawing a rune, chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 3 SECONDS
		else
			self = "You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 4 SECONDS
	else
		self = "Working without your codex, you try to draw the rune from your memory"
		if(has_robes)
			self += ". You don't remember it well, but you feel strangely empowered. You begin chanting, the unknown words slipping into your mind from beyond."
			timer = 5 SECONDS
		else
			self += ", having to cut your finger two more times before you make it resemble the pattern in your memory. It still looks a little off."
			timer = 8 SECONDS
	visible_message(SPAN_WARNING("\The [src] slices open a finger and begins to chant and paint symbols on the floor."), SPAN_NOTICE("[self]"), "You hear chanting.")
	if(do_after(src, timer, T, DO_PUBLIC_UNIQUE))
		if(locate(/obj/rune) in T)
			return
		var/obj/rune/R = new rune(T, get_rune_color(), get_blood_name())
		var/area/A = get_area(R)
		log_and_message_admins("created \an [R.cultname] rune at \the [A.name].")
		R.add_fingerprint(src)
		return 1
	return 0


/obj/rune/alchemy
	name = "rune"
	desc = "A strange collection of symbols drawn in blood."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune3"

	var/list/req = list()

	var/mob/living/victim

	var/is_in_use = FALSE

/obj/rune/alchemy/on_update_icon()
	ClearOverlays()

/obj/rune/alchemy/proc/get_heretics()
	. = list()
	for(var/mob/living/M in range(1, src))
		if(isheretic(M))
			. += M


/obj/rune/alchemy/examine(mob/user, distance)
	. = ..()
	if (distance <= 0)
		to_chat(user, "It currently holds fabrication units.")


/**
 * Attempt to begin a ritual, giving them an input list to chose from.
 * Also ensures is_in_use is enabled and disabled before and after.
 */
/obj/rune/alchemy/attack_hand(mob/living/user)

	if(!isheretic(user))
		return FALSE
	else
		// invoke_async(src, PROC_REF(try_rituals), user)
		try_rituals(user)
		return TRUE

/obj/rune/alchemy/proc/try_rituals(mob/living/user)
	is_in_use = TRUE

	var/list/rituals = user.mind.heretic.known_rituals // researched_knowledge
	if(!length(rituals))
		to_chat(user, SPAN_WARNING("no rituals available!"))
		is_in_use = FALSE
		return

	var/radial = list()
	for (var/alchemy in rituals)
		var/datum/heretic_knowledge/ritual = alchemy
		radial[ritual] = mutable_appearance('mods/heretic/icons/heretic_misc.dmi', ritual.icon)
	var/choice = show_radial_menu(user, user, radial, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if(!choice)
		return
	var/chosen_ritual = new choice
	if(!chosen_ritual || !istype(chosen_ritual, /datum/heretic_knowledge))
		is_in_use = FALSE
		return
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)

	do_ritual(user, chosen_ritual)
	is_in_use = FALSE

/obj/rune/alchemy/proc/do_ritual(mob/living/user, datum/heretic_knowledge/ritual)

	// Collect all nearby valid atoms over the rune for processing in rituals.
	var/list/atom/movable/atoms_in_range = list()
	// First rule of alchemy: Don't step into alchemy circle
	var/turf/T = get_turf(src)
	for(var/atom/close_atom as anything in T)
		if(!ismovable(close_atom))
			continue
		if(close_atom.invisibility)
			continue
		if(close_atom == user)
			continue

		atoms_in_range += close_atom

	var/list/requirements_list = ritual.required_atoms.Copy()
	// A list of all atoms we've selected to use in this recipe.
	var/list/selected_atoms = list()

	var/list/stack_reqs = list()

	// Now go through all our nearby atoms and see which are good for our ritual.
	for(var/atom/nearby_atom as anything in atoms_in_range)
		// Go through all of our required atoms
		for(var/req_type in requirements_list)
			// We already have enough of this type, skip
			if(requirements_list[req_type] <= 0)
				continue
			// If req_type is a list of types, check all of them for one match.
			if(islist(req_type))
				if(!is_type_in_list(nearby_atom, req_type))
					continue
			else if(!istype(nearby_atom, req_type))
				continue
			// If it's a stack, we gotta see if it has more than one inside,
			// as our requirements may want more than one item of a stack
			// It's also important that we split the required amount from the stack and add that
			// to the selected_atoms AFTERWARD so we don't change anything if the reqs aren't met.
			if(isstack(nearby_atom))
				var/obj/item/stack/picked_stack = nearby_atom
				if(!stack_reqs[req_type])
					stack_reqs[req_type] = requirements_list[req_type]
				requirements_list[req_type] -= min(picked_stack.amount, requirements_list[req_type])

			// Otherwise, just add the mark down the item as fulfilled x1
			else
				requirements_list[req_type]--
				// This item is a valid type. Add it to our selected atoms list.
				selected_atoms |= nearby_atom

	// All of the atoms have been checked, let's see if the ritual was successful
	var/list/what_are_we_missing = list()
	for(var/req_type in requirements_list)
		var/number_of_things = requirements_list[req_type]
		// <= 0 means it's fulfilled, skip
		if(number_of_things <= 0)
			continue

		// > 0 means it's unfilfilled - the ritual has failed, we should tell them why
		// Lets format the thing they're missing and put it into our list
		var/formatted_thing = "[number_of_things] "
		if(islist(req_type))
			var/list/req_type_list = req_type
			var/list/req_text_list = list()
			for(var/atom/possible_type as anything in req_type_list)
				req_text_list += ritual.parse_required_item(possible_type)
			formatted_thing += english_list(req_text_list, and_text = "or")

		else
			formatted_thing = ritual.parse_required_item(req_type)

		what_are_we_missing += formatted_thing

	if(length(what_are_we_missing))
		// Let them know it screwed up
		to_chat(user, SPAN_WARNING("ritual failed, missing required_atoms!"))
		// Then let them know what they're missing
		to_chat(user, SPAN_OCCULT("You are missing [english_list(what_are_we_missing)] in order to complete the ritual \"[ritual.name]\"."))
		return FALSE

	//Everything's good, proceed and collect from the available stacks what's needed if needed.
	if(length(stack_reqs))
		for(var/obj/item/stack/nearby_stack in atoms_in_range)
			for(var/stack_path in stack_reqs)
				if(!istype(nearby_stack, stack_path) && (!islist(stack_path) || !is_type_in_list(nearby_stack, stack_path)))
					continue
				var/amount_to_give = min(nearby_stack.amount, stack_reqs[stack_path])
				var/obj/item/stack/our_stack = locate(nearby_stack.stacktype) in selected_atoms
				if(!our_stack)
					our_stack = nearby_stack.split(amount_to_give)
					selected_atoms |= our_stack
				else
					var/target_amount = our_stack.amount + amount_to_give
					nearby_stack.transfer_to(our_stack, target_amount)

	// If we made it here, the ritual had all necessary required_atoms, and we can try to cast it.
	// This doesn't necessarily mean the ritual will succeed, but it's valid!
	// Do the animations and associated feedback.
	flick("[icon_state]_active", src)
	playsound(user, 'sound/ambience/meat_monster_arrival.ogg', 50, TRUE, extrarange = -3)

	// - We temporarily make all of our chosen atoms invisible, as some rituals may sleep,
	// and we don't want people to be able to run off with ritual items.
	// - We make a duplicate list here to ensure that all atoms are correctly un-invisibled by the end.
	// Some rituals may remove atoms from the selected_atoms list, and not consume them.
	var/list/initial_selected_atoms = selected_atoms.Copy()
	for(var/atom/to_disappear as anything in selected_atoms)
		to_disappear.set_invisibility(INVISIBILITY_ABSTRACT)

	// All the required_atoms have been invisibled, time to actually do the ritual. Call on_finished_recipe
	// (Note: on_finished_recipe may sleep in the case of some rituals like summons, which expect ghost candidates.)
	// - If the ritual was success (Returned TRUE), proceede to clean up the atoms involved in the ritual. The result has already been spawned by this point.
	// - If the ritual failed for some reason (Returned FALSE), likely due to no ghosts taking a role or an error, we shouldn't clean up anything, and reset.
	var/ritual_result = ritual.on_finished_recipe(user, selected_atoms, loc)

	// Calling this second time cause
	// ritual.on_finished_recipe(user, selected_atoms, loc)

	if(ritual_result)
		ritual.cleanup_atoms(selected_atoms)

	// Clean up done, re-appear anything that hasn't been deleted.
	for(var/atom/to_appear as anything in initial_selected_atoms)
		if(QDELETED(to_appear))
			continue
		to_appear.set_invisibility(INVISIBILITY_NONE)
		// Stacks are split off into nullspace and need to be brought back
		if (isstack(to_appear) && isnull(to_appear.loc))
			var/obj/item/stack/as_stack = to_appear
			as_stack.forceMove(loc)

	// And finally, give some user feedback
	// No feedback is given on failure here -
	// the ritual itself should handle it (providing specifics as to why it failed)
	if(ritual_result)
		to_chat(user, SPAN_OCCULT("ritual complete"))

	return ritual_result
