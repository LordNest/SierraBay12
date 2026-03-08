/* /obj/item/spellbook/heretic/flesh
	spellbook_type = /datum/spellbook/heretic/flesh

/datum/spellbook/heretic/flesh
	name = "\improper Pale Herald Grimoure"
	feedback = "FL"
	desc = "It smells like an air freshener."
	book_desc = "Summons, nature, and a bit o' healin."
	title = "Druidic Guide on how to be smug about nature"
	title_desc = "Buy spells using your available spell slots. Artefacts may also be bought however their cost is permanent."
	book_flags = NOREVERT|NO_LOCKING
	max_uses = 6

	spells = list(/spell/targeted/fleshmend = 					1,
				/spell/targeted/sensory_overload = 				1,
				/spell/targeted/blood_siphon = 					1,
				/spell/targeted/galvanization = 				1,
				/spell/targeted/flex =		 					1,
				/spell/targeted/vicissitude = 					1,
				/spell/cleave = 								1,
				/obj/structure/closet/wizard/souls = 				1,
				/obj/item/magic_rock = 						1,
				/obj/item/summoning_stone = 					2,
				/obj/item/contract/wizard/telepathy = 		1,
				)
 */
/*
TIER ONE
*/

/datum/power/heretic/flesh
	path = HERETIC_POWER_FLESH
	make_hud_button = 1

/datum/power/heretic/flesh/fleshmend
	tier = HERETIC_TIER_ONE
	name = "Fleshmend"
	desc = "Ценой голода лечит урон, нанесённый владельцу. Может использоваться даже в бессознательном состоянии."
	ability_icon_state = "fleshmend"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/heretic_fleshmend

/mob/proc/heretic_fleshmend()
	set category = "Heretic"
	set name = "Fleshmend"
	set desc = "Ценой голода лечит урон, нанесённый владельцу. Может использоваться даже в бессознательном состоянии."

//Starts healing you every second for 50 seconds. Can be used whilst unconscious.


//////////////////////////////////////////////////////

/datum/power/heretic/flesh/sensory_overload
	tier = HERETIC_TIER_ONE
	name = "Sensory Overload"
	desc = "Воздействие на ЦНС или её подобие заставляет жертву испытывать жуткую агонию, после того, как вы её коснетесь"
	ability_icon_state = "overload"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/sensory_overload

/mob/proc/sensory_overload()
	set category = "Heretic"
	set name = "Sensory Overload"
	set desc = "Добавить"

/*
TIER TWO
*/

/datum/power/heretic/flesh/blood_siphon
	tier = HERETIC_TIER_TWO
	name = "Blood Siphon"
	desc = "вытягивает в АоЕ кровь, лечит раны, собирает кровь с пола (привет культ, как вы там?)."
	ability_icon_state = "siphon"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/blood_siphon

/mob/proc/blood_siphon()
	set category = "Heretic"
	set name = "Blood Siphon"
	set desc = "Добавить"


//////////////////////////////////////////////////////

/datum/power/heretic/flesh/galvanization
	tier = HERETIC_TIER_TWO
	name = "Create Ghoul"
	desc = "Resurrects dead target in form of a loyal ghoul. You can only have three ghouls."
	ability_icon_state = "ghoul"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/galvanization

/mob/proc/galvanization()

/mob/proc/blood_siphon()
	set category = "Heretic"
	set name = "Create Ghoul"
	set desc = "Добавить"

/*
	var/should_wait = 1
	for(var/t in targets)
		var/mob/living/carbon/human/M = t
		M.rejuvenate()
		M.Drain()
		if(M.client) //We've got a dude
			should_wait = 0
			break //Don't need to check anymore.
	if(should_wait)
		addtimer(new Callback(src,PROC_REF(check_for_ghoul),targets), 30 SECONDS)
	else
		return TRUE
 */
/*
/spell/targeted/galvanization/proc/check_for_ghoul(list/targets)
	for(var/t in targets)
		var/mob/living/carbon/human/M = t
		if(M.client)
			return
	charge_counter += 1
	to_chat(holder,SPAN_NOTICE("You cannot galvanize soulles husk."))
 */

/*
TIER THREE
*/

/datum/power/heretic/flesh/vicissitude
	name = "Vicissitude"
	desc = "Позволяет проводить хирургические операции (в том числе на себе) без необходимых навыков и без инструментов"
	ability_icon_state = "vicissitude"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/vicissitude

/mob/proc/vicissitude()
	set category = "Heretic"
	set name = "Vicissitude"
	set desc = "Добавить"
