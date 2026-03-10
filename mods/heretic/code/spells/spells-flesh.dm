/*
TIER ONE
*/

/datum/power/heretic/fleshmend
	path = HERETIC_POWER_FLESH
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

/datum/power/heretic/sensory_overload
	path = HERETIC_POWER_FLESH
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

/datum/power/heretic/blood_siphon
	path = HERETIC_POWER_FLESH
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

/datum/power/heretic/galvanization
	path = HERETIC_POWER_FLESH
	tier = HERETIC_TIER_TWO
	name = "Create Ghoul"
	desc = "Resurrects dead target in form of a loyal ghoul. You can only have three ghouls."
	ability_icon_state = "ghoul"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/galvanization

/mob/proc/galvanization()
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

/datum/power/heretic/vicissitude
	path = HERETIC_POWER_FLESH
	tier = HERETIC_TIER_THREE
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
