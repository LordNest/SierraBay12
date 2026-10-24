///An ID card capable of shapeshifting to other IDs given by the Key Keepers Burden knowledge
/obj/item/card/id/heretic
	access = list(access_heretic)
	///List of IDs this card consumed
	var/list/obj/item/card/id/fused_ids = list()

/obj/item/card/id/heretic/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	. += SPAN_OCCULT("Enchanted by the Mansus!")
	. += SPAN_OCCULT("Using an ID on this or using this ID on another ID will consume it and allow you to copy its accesses.")
	. += SPAN_OCCULT("<b>Using this in-hand</b> allows you to change its appearance.")
	. += SPAN_OCCULT("<b>Using this on a pair of doors</b>, allows you to link them together. Entering one door will transport you to the other, while heathens are instead teleported to a random airlock.")
	. += SPAN_OCCULT("<b>Ctrl-clicking the ID</b>, makes the ID make inverted portals instead, which teleport you onto a random airlock onstation, while heathens are teleported to the destination.")

/obj/item/card/id/heretic/attack_self(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	var/cardname = alert(user, "Shapeshift into?", "Shapeshift", fused_ids)
	if(!cardname)
		alert(user, "no options!")
		return ..()
	var/obj/item/card/id/card = fused_ids[cardname]
	shapeshift(card)

///Changes our appearance to the passed ID card
/obj/item/card/id/heretic/proc/shapeshift(obj/item/card/id/card)
	age = card.age
	formal_name_prefix = card.formal_name_prefix
	formal_name_suffix = card.formal_name_suffix
	assignment = card.assignment
	blood_type = card.blood_type
	dna_hash = card.dna_hash
	fingerprint_hash = card.fingerprint_hash
	icon_state = card.icon_state
	color = card.color
	detail_color = card.detail_color
	extra_details = card.extra_details
	SetName(card.name)
	registered_name = card.registered_name
	sex = card.sex
	military_branch = card.military_branch
	military_rank = card.military_rank
	name = card.name //not update_label because of the captains spare moment
	update_icon()

/obj/item/card/id/heretic/use_tool(obj/item/item, mob/living/user, list/click_params)
	// . = ..()
	if(!istype(item, /obj/item/card/id) || !isheretic(user))
		return ..()
	eat_card(item, user)
	return TRUE

/obj/item/card/id/heretic/proc/eat_card(obj/item/card/id/card, mob/user)
	if(card == src)
		return //no self vore
	fused_ids[card.name] = card
	// card.moveToNullspace()
	access |= card.access
	if(!isnull(user))
		playsound(user, 'sound/items/eatfood.ogg', rand(10,30), TRUE)
		user.visible_message(SPAN_WARNING("consumed card"))

/* /obj/item/card/id/heretic/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isheretic(user))
		return NONE
	if(istype(target, /obj/item/card/id))
		eat_card(target, user)
		return TRUE
	if(!istype(target, /obj/machinery/door))
		return NONE */

/obj/item/card/id/heretic/Destroy()
	QDEL_NULL_ASSOC_LIST(fused_ids)
	return ..()
