/* /obj/item/spellbook/heretic/hunt
	spellbook_type = /datum/spellbook/heretic/hunt

/datum/spellbook/heretic/hunt
	name = "\improper Huntsman Catalogue"
	feedback = "HT"
	desc = "It smells like an air freshener."
	book_desc = "Summons, nature, and a bit o' healin."
	title = "Druidic Guide on how to be smug about nature"
	title_desc = "Buy spells using your available spell slots. Artefacts may also be bought however their cost is permanent."
	book_flags = NOREVERT|NO_LOCKING
	max_uses = 6

	spells = list(/spell/targeted/heal_target = 					1,
				/spell/targeted/heal_target/sacrifice = 			1,
				/spell/aoe_turf/conjure/mirage = 					1,
				/spell/aoe_turf/conjure/summon/bats = 				1,
				/spell/targeted/equip_item/party_hardy = 			1,
				/spell/targeted/equip_item/seed = 					1,
				/spell/targeted/shapeshift/avian = 					1,
				/spell/aoe_turf/disable_tech = 						1,
				/spell/hand/charges/entangle = 						1,
				/spell/aoe_turf/conjure/grove/sanctuary = 			1,
				/spell/aoe_turf/knock = 							1,
				/spell/area_teleport = 								2,
				/spell/portal_teleport = 							2,
				/spell/noclothes = 									1,
				/obj/structure/closet/wizard/souls = 				1,
				/obj/item/magic_rock = 						1,
				/obj/item/summoning_stone = 					2,
				/obj/item/contract/wizard/telepathy = 		1,
				/obj/item/contract/apprentice = 				1
				) */

/*
TIER ONE
*/

/datum/power/heretic/hunt
	path = HERETIC_POWER_HUNT
	make_hud_button = 1

/datum/power/heretic/hunt/passion
	tier = HERETIC_TIER_ONE
	name = "Huntsman Passion"
	desc = "a rudimentary spell used mainly by wizards to heal papercuts. Does not require wizard garb."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/hunter_passion

/mob/proc/hunter_passion()
	set category = "Heretic"
	set name = "Huntsman Passion"
	set desc = "Добавить"

//////////////////////////////////////////////////////

/datum/power/heretic/hunt/hunter_whiste
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

/*
TIER TWO
*/

/datum/power/heretic/hunt/huntsman_instincts
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

/datum/power/heretic/hunt/huntsman_return
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

/datum/power/heretic/hunt/miststep
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
