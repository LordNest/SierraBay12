/*
TIER ONE
*/

/datum/power/heretic/passion
	path = HERETIC_POWER_HUNT
	tier = HERETIC_TIER_ONE
	name = "Huntsman Passion"
	desc = "Снимает статусы."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/hunter_passion

/mob/proc/hunter_passion()
	set category = "Heretic"
	set name = "Huntsman Passion"
	set desc = "Добавить"

//////////////////////////////////////////////////////

/datum/power/heretic/hunter_whiste
	path = HERETIC_POWER_HUNT
	tier = HERETIC_TIER_ONE
	name = "Huntsman Whiste"
	desc = "Все лампы в зоне видимости с треском перегорают, а персональные источники света отключаются."
	ability_icon_state = "scream"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/hunter_whiste

/mob/proc/hunter_whiste()
	set category = "Heretic"
	set name = "Huntsman Whiste"
	set desc = "Добавить"

	for(var/obj/machinery/light/L in range(5))
		playsound(loc, 'sound/effects/ghost2.ogg', 50, TRUE)
		L.broken()

/*
TIER TWO
*/

/datum/power/heretic/huntsman_instincts
	path = HERETIC_POWER_HUNT
	tier = HERETIC_TIER_TWO
	name = "Huntsman Instincts"
	desc = "Пассивная возможность слышать шаги за стенами, а также отсутствие ФОВ в броне и мехах."
	ability_icon_state = "instinct_off"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/huntsman_instinct

/mob/proc/huntsman_instinct()
	set category = "Heretic"
	set name = "Huntsman Instincts"
	set desc = "Добавить"

	var/mob/living/carbon/human/C = src
	C.resomi_sonar_ping()

//////////////////////////////////////////////////////

/datum/power/heretic/huntsman_return
	path = HERETIC_POWER_HUNT
	tier = HERETIC_TIER_TWO
	name = "Huntsman Return"
	desc = "Возвращает вас к последнему фонарю из которого вы перемещались в сон."
	ability_icon_state = "return"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/huntsman_return

/mob/proc/huntsman_return()
	set category = "Heretic"
	set name = "Huntsman Return"
	set desc = "Добавить"

/* /spell/mark_recall/huntsman_return/choose_targets()
	if(!mark)
		return list("magical fairy dust") //because why not
	else
		return list(mark)

/spell/mark_recall/huntsman_return/cast(list/targets,mob/user)
	if(!length(targets))
		return 0
	var/target = targets[1]
	if(istext(target))
		mark = new /obj/cleanable/wizard_mark(get_turf(user),src)
		return 1
	if(!istype(target,/obj)) //something went wrong
		return 0
	var/turf/T = get_turf(target)
	if(!T)
		return 0
	user.forceMove(T)
	..()

/spell/mark_recall/huntsman_return/empower_spell()
	if(!..())
		return 0

	spell_flags = NO_SOMATIC

	return "You will always be able to cast this spell, even while unconscious or handcuffed." */

/obj/cleanable/wizard_mark/lanthern
	name = "\improper Mark of the Wizard"
	desc = "A strange rune said to be made by wizards. Or its just some shmuck playing with crayons again."
	icon = 'icons/obj/rune.dmi'
	icon_state = "wizard_mark"

	anchored = TRUE
	unacidable = TRUE
	layer = TURF_LAYER

/obj/cleanable/wizard_mark/lanthern/New(newloc,mrspell)
	..()
	spell = mrspell

/obj/cleanable/wizard_mark/lanthern/Destroy()
	spell.mark = null //dereference pls.
	spell = null
	..()

/obj/cleanable/wizard_mark/lanthern/attack_hand(mob/user)
	if(user == spell.holder)
		user.visible_message("\The [user] mutters an incantation and \the [src] disappears!")
		qdel(src)
	..()


/obj/cleanable/wizard_mark/lanthern/use_tool(obj/item/tool, mob/user, list/click_params)
	// Null Rod or Spell Book - Remove mark
	if (is_type_in_list(tool, list(/obj/item/nullrod, /obj/item/spellbook)))
		user.visible_message(
			SPAN_NOTICE("\The [user] waves \a [tool] over \the [src], and it fades away."),
			SPAN_NOTICE("You wave \the [tool] over \the [src], and it fades away.")
		)
		qdel(src)
		return TRUE

	return ..()

/*
TIER THREE
*/

/datum/power/heretic/miststep
	path = HERETIC_POWER_HUNT
	tier = HERETIC_TIER_THREE
	name = "Miststep"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	ability_icon_state = "miststep"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/huntsman_miststep

/mob/proc/huntsman_miststep()
	set category = "Heretic"
	set name = "Miststep"
	set desc = "Добавить"
