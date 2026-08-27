/*
Много копипаста тома культистов + функционал для выбора пути. В базе своей мы просто копипастим. Наше преимущество? Стиль, сука, стиль.
Книжка умеет делать разные приколы, пока реализуем флеш на дизарме раз в минуту.
Ну и нож, куда без него.
*/

/obj/item/book/codex_cicatrix
	name = "codex cicatrix"
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "tome"
	throw_speed = 1
	throw_range = 5
	w_class = 2
	unique = 1
	carved = 2 // Аналогично тому культистов мы это не режем
	var/recharging = 0
	var/last_used = 0 //last world.time it was used.

/obj/item/book/codex_cicatrix/attack_self(mob/living/user)
	if(recharging)
		if(!isheretic(user))
			to_chat(user, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
		else
			to_chat(user, "Сила сокрытая в \ [src] недавно была использована и востановится в течение минуты. Имей терпение.")
	if(iscultist(user) || isheretic(user))
		to_chat(user, "Держи \ [src] в руке, во время жертвоприношений и создания алхимического круга. Обезоружь жертву, целясь книгой в глаза, чтобы открыть ярко сияющую страницу и ослепить её.")
	else
		to_chat(user, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
	codex_recharge()

/obj/item/book/codex_cicatrix/examine(mob/user)
	. = ..()
	if(iscultist(user) || isheretic(user))
		to_chat(user, "Некрономикон мой некрономикон.")
	else
		to_chat(user, "An old, dusty tome with frayed edges and a sinister looking cover.")
	codex_recharge()

// Люблю спагетти.

/obj/item/book/codex_cicatrix/use_before(mob/living/M, mob/living/user)
	. = FALSE
	if (!istype(M))
		return FALSE
	if (user.a_intent == I_HELP && user.zone_sel.selecting == BP_EYES)
		user.visible_message(
			SPAN_NOTICE("\The [user] shows \the [src] to \the [M]."),
			SPAN_NOTICE("You open up \the [src] and show it to \the [M].")
		)
		if (iscultist(M))
			if (user != M)
				to_chat(user, SPAN_NOTICE("But they already know all there is to know."))
			to_chat(M, SPAN_NOTICE("But you already know all there is to know."))
		else
			to_chat(M, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if (user.a_intent == I_DISARM && user.zone_sel.selecting == BP_EYES)
		for(M in viewers(src))
			if(!isheretic(user))
				user.visible_message(
					SPAN_NOTICE("\The [user] shows \the [src] to \the [M]."),
					SPAN_NOTICE("You open up \the [src] and show it to \the [M].")
				)
				return
			if(recharging)
				user.visible_message(
					SPAN_NOTICE("\The [user] shows \the [src] to \the [M]."),
					SPAN_NOTICE("You open up \the [src] intended to blind [M] but powers of the book still asleep and you casually show it to \the [M].")
				)
			if(iscarbon(M))
				var/obj/item/nullrod/N = locate() in M
				if(N)
					continue
				if(issilicon(M))
					M.Weaken(10)
				else
					M.flash_eyes()
					M.eye_blurry += 50
					M.Weaken(3)
					M.Stun(5)
			user.visible_message(
				SPAN_NOTICE("\The [user] shows \the [src], emitting blinding light to \the [M]."),
				SPAN_NOTICE("You open up \the [src], it's pages bright with searing light, and show it to \the [M]."))
			last_used = world.time
			recharging++
			if (iscultist(M))
				if (user != M)
					to_chat(user, SPAN_NOTICE("But they already know all there is to know."))
				to_chat(M, SPAN_NOTICE("But you already know all there is to know."))
			else
				to_chat(M, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
			codex_recharge()
			return TRUE

// Хотим как флешка раз в минуту поднимать чардж

/obj/item/book/codex_cicatrix/proc/codex_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		recharging -= 1
	last_used = world.time
	recharging = max(0,round(recharging)) //sanity

/*
Вострый нож
Carving Knife, как с ТГ но не как с ТГ.
Всё у чего есть путь /obj/item/material/knife может им быть, нужно только захотеть, но пока отрисуем основной нож
Основное использование - быть фокусом для жертвоприношения. То есть именно ножик с историей у нас путём удара в сердце стартует ритуал
*/

/obj/item/material/knife/heretic
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/cult.dmi'
	icon_state = "render"
	base_parry_chance = 30
	applies_material_colour = FALSE
	applies_material_name = FALSE

/obj/item/melee/sickly_blade

/obj/item/material/coin/challenge/eldritch

/obj/item/melee/rune_carver

// Чашки

/obj/item/reagent_containers/phylactery

// Наркотики, алкоголь

/obj/item/ether
	name = "ether of the newborn"
	desc = "A flask of nausea-inducing, thick green liquid. Restores your body completely, then places you into an enhanced sleep for a full minute."
	icon = 'mods/heretic/icons/eldritch.dmi'
	icon_state = "poison_flask"

/obj/item/ether/attack_self(mob/living/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	user.revive()
	for(var/obj/item/implant/I in user.contents)
		for(var/obj/item/organ/external/organs in H.organs)
			if(I in organs.implants)
				Destroy(I)

	// user.apply_status_effect(/datum/status_effect/eldritch_sleep)
	user.SetSleeping(60 SECONDS)
	qdel(src)


/*
 * Focuses, amulets, etc
 */

/obj/item/clothing/accessory/amulet/heretic_focus
	icon_state = "taj_amulet"
	icon = 'mods/tajara/icons/obj_accessories.dmi'
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_MASK | SLOT_TIE
	heretic_focus = TRUE

/obj/item/clothing/accessory/amulet/eldritch_amulet
	icon_state = "taj_amulet_3"
	icon = 'mods/tajara/icons/obj_accessories.dmi'
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_MASK | SLOT_TIE
	heretic_focus = TRUE

/*
 * Void Cloak zone
 */

/obj/item/clothing/suit/storage/hooded/cultrobes/void
	icon = 'mods/heretic/icons/obj/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/heretic/icons/mob/onmob_suit.dmi')
	icon_state = "void_cloak"

	flags_inv = HIDEJUMPSUIT

	item_flags = ITEM_FLAG_THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS

	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_RESISTANT
		)

/obj/item/clothing/suit/storage/hooded/cultrobes/void/ToggleHood()
	. = ..()
	hood_up = TRUE
	heretic_focus = FALSE
	min_pressure_protection = 0 // Hard vacuum protection on
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS

/obj/item/clothing/suit/storage/hooded/cultrobes/void/RemoveHood()
	. = ..()
	hood_up = FALSE
	heretic_focus = TRUE
	min_pressure_protection = null // Hard vacuum protection off
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS

// Since we can't have entire trait system on Bay, here's a temporal solution
/obj/item/clothing/suit/storage/hooded/cultrobes/void/get_examine_line()
	return

/obj/item/clothing/head/hooded/cult_hoodie/void
	icon = 'mods/heretic/icons/obj/obj_head.dmi'
	icon_state = "void_cloak"
	item_icons = list(slot_head_str = 'mods/heretic/icons/mob/onmob_head.dmi')
	cold_protection = HEAD
	armor = list(
		melee = ARMOR_MELEE_RESISTANT,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_RESISTANT
		)
	min_pressure_protection = 0

// Since we can't have entire trait system on Bay, here's a temporal solution
/obj/item/clothing/head/hooded/cult_hoodie/void/get_examine_line()
	return

/*
 * Contains the eldritch robes for heretics, a suit of armor that they can make via a ritual
 */

	// Father of all heretic robes
/obj/item/clothing/suit/storage/hooded/cultrobes
	/// Whether the hood is flipped up
	var/hood_up = FALSE
	action_button_name = "Toggle Mantle Hood"

/obj/item/clothing/head/hooded/cult_hoodie

// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon = 'mods/heretic/icons/obj/obj_suit.dmi'
	item_icons = list(slot_wear_suit_str = 'mods/heretic/icons/mob/onmob_suit.dmi')
	icon_state = "eldritch_armor"
	flags_inv = HIDESHOES | HIDEJUMPSUIT

	item_flags = ITEM_FLAG_THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/cult_hoodie/eldritch
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
		)
	heretic_focus = TRUE

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot_flags & slot))
		return
	if(!isheretic(user))
		robes_side_effect(user)
		return
	// Heretic equipped the robes? Grant them the effects
	on_robes_gained(user)

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/dropped(mob/living/user)
	. = ..()
	on_robes_lost(user)

/// Adds effects to the user when they equip their robes
/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/proc/on_robes_gained(mob/living/user)
	return

/// Removes any effects that our robes have, returns `TRUE` if the item dropped was not robes
/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/proc/on_robes_lost(mob/living/user)
	return

/// Applies a punishment to the user when the robes are equipped
/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/proc/robes_side_effect(mob/living/user)
	SHOULD_NOT_SLEEP(TRUE) // sleep here would fuck over the timing

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/ToggleHood()
	. = ..()
	hood_up = TRUE

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/RemoveHood()
	. = ..()
	hood_up = FALSE

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return
	if(hood_up)
		return

	// Our hood gains the heretic_focus element.
	. += SPAN_NOTICE("Allows you to cast heretic spells while the hood is up.")

/obj/item/clothing/head/cult_hoodie/eldritch
	name = "ominous hood"
	icon = 'mods/heretic/icons/obj/obj_head.dmi'
	icon_state = "eldritch"
	item_icons = list(slot_wear_suit_str = 'mods/heretic/icons/mob/onmob_head.dmi')
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | BLOCKHAIR
	item_flags = ITEM_FLAG_THICKMATERIAL | ITEM_FLAG_PHORONGUARD
	body_parts_covered = HEAD|FACE|EYES
	flash_protection = FLASH_PROTECTION_MAJOR
	cold_protection = HEAD
	armor = list(
		melee = ARMOR_MELEE_MAJOR,
		bullet = ARMOR_BALLISTIC_PISTOL,
		laser = ARMOR_LASER_MAJOR,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED
		)

	heretic_focus = TRUE

/obj/item/clothing/head/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
//	AddElement(/datum/element/heretic_focus)



/obj/item/clothing/head/cult_hoodie/eldritch/attack_hand(mob/living/carbon/human/H)
	if(src == H.head)
		return
	..()


// Organs

/obj/item/organ/internal/appendix/corrupt

/obj/item/organ/internal/eyes/corrupt

/obj/item/organ/internal/heart/corrupt

/obj/item/organ/internal/liver/corrupt

/obj/item/organ/internal/lungs/corrupt

/obj/item/organ/internal/stomach/corrupt

/obj/item/organ/internal/tongue/corrupt


// Some various defines used in the heretic sacrifice map.

/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
GLOBAL_LIST_EMPTY(heretic_sacrifice_landmarks)

/// Lardmarks meant to designate where heretic sacrifices are sent.
/obj/landmark/heretic
	name = "default heretic sacrifice landmark"
	icon_state = "x"
	/// What path this landmark is intended for.
	var/for_heretic_path = PATH_START

/obj/landmark/heretic/Initialize(mapload)
	. = ..()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = src

/obj/landmark/heretic/Destroy()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = null
	return ..()
/*
/obj/landmark/heretic/ash
	name = "ash heretic sacrifice landmark"
	for_heretic_path = PATH_ASH
*/
