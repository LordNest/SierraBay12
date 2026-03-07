// Живое сердце
// Точно не предмет порочной связи между ядром линга и книжкой мага

/obj/item/organ/internal/augment/active/livingheart
	name = "bizarre mass"
	desc = "a twitching, pulsating mass that almost resembles a deformed embryo"
	icon_state = "lingcore"
	w_class = ITEM_SIZE_TINY
	augment_slots = AUGMENT_CHEST
	status = ORGAN_CONFIGURE
	augment_flags = AUGMENT_BIOLOGICAL
	var/ownerckey
	var/book

/obj/item/organ/internal/augment/active/livingheart/emp_act()
	..()
	return
/obj/item/organ/internal/augment/active/livingheart/getToxLoss()
	return 0

/obj/item/organ/internal/augment/active/livingheart/Initialize()
	. = ..()
	create_reagents(5)


/obj/item/organ/internal/augment/active/livingheart/activate()

	if(!reagents)
		return

	var/list/choices = list(
		"Draw" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-draw"),
		"Inject" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-inject"),
		"Bite" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-bite"),
		"Gulp" = mutable_appearance('mods/RnD/icons/augment.dmi', "vampire-gulp")
	)

	var/choice = show_radial_menu(usr, usr, choices, radius = 42, require_near = TRUE, tooltips = TRUE, check_locs = list(src))

	switch(choice)
		if("Draw")
		//	draw_from_container(owner)
		if("Inject")
		//	inject(owner)
		if("Bite")
		//	attack_target(owner)
		if("Gulp")
		//	gulp(owner)

/obj/item/organ/internal/heart/livingheart
	name = "compound eyes"
	action_button_name = "Toggle Eye Shields"

/obj/item/organ/internal/heart/livingheart/attack_self(mob/user)
	. = ..()
	if(.)
		owner.mind.heretic.book.attack_self(owner)
