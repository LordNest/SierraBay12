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

/*
TIER ONE
*/

/spell/targeted/fleshmend
	tier = HERETIC_TIER_ONE
	name = "Fleshmend"
	desc = "Ценой голода лечит урон, нанесённый владельцу. Может использоваться даже в бессознательном состоянии."
	hud_state = "friendly"
	school = "heretical"
//	knowledgecost = 1
//	icon = 'mods/heretic/icons/heretic_powers.dmi'
	range = 0
	max_targets = 1

/mob/proc/end_hereticmend()
	to_chat(src, "<span class='notice'>Our regeneration has slowed to normal levels.</span>")
	src.verbs += /mob/proc/heretic_fleshmend
	var/datum/heretic/heretic = src.mind.heretic
	heretic.already_regenerating = FALSE

//Starts healing you every second for 50 seconds. Can be used whilst unconscious.

/mob/proc/heretic_fleshmend()
	set category = "heretic"
	set name = "Fleshmend (10)"
	set desc = "Begins a slow rengeration of our form.  Does not effect stuns or chemicals."
	set waitfor = FALSE
	var/datum/heretic/heretic = heretic_power(10,0,100,UNCONSCIOUS)
	if(!heretic)
		return
	var/mob/living/carbon/human/C = src
	if(C.on_fire)
		to_chat(src,SPAN_DANGER("We cannot regenerate while engulfed in flames!"))
		return
	if(heretic.already_regenerating)
		to_chat(src,SPAN_DANGER("We are already regenerating our flesh."))
		return
	var/heal_amount = 2
	if(src.mind.heretic.recursive_enhancement)
		src.mind.heretic.recursive_enhancement = FALSE
		heal_amount = heal_amount * 2
		to_chat(src, "<span class='notice'>We will heal much faster.</span>")

	to_chat(src, "<span class='notice'>We begin to heal ourselves.</span>")
	heretic.already_regenerating = TRUE
	for(var/i = 0, i<50,i++)
		if(C && !C.on_fire)
			C.adjustBruteLoss(-heal_amount)
			C.adjustOxyLoss(-heal_amount)
			C.adjustFireLoss(-heal_amount)
			C.regenerate_icons()
			sleep(1 SECOND)

	src.verbs -= /mob/proc/heretic_fleshmend
	addtimer(new Callback(src,/mob/.proc/end_hereticmend), 50 SECONDS)

//////////////////////////////////////////////////////

/spell/targeted/sensory_overload
	tier = HERETIC_TIER_ONE
	name = "Sensory Overload"
	desc = "Воздействие на ЦНС или её подобие заставляет жертву испытывать жуткую агонию, после того, как вы её коснетесь"
//	knowledgecost = 1

	range = 1
//	max_target = 1

/*
TIER TWO
*/

/spell/targeted/blood_siphon
	tier = HERETIC_TIER_TWO
	name = "Blood Siphon"
	desc = "вытягивает в АоЕ кровь, лечит раны, собирает кровь с пола (привет культ, как вы там?)."
	feedback = "BS"
	school = "heretical"
	charge_max = 300
	spell_flags = 0
	invocation_type = SpI_NONE
	range = 5
	max_targets = 1
	compatible_mobs = list(/mob/living/carbon/human)

	time_between_channels = 50
	number_of_channels = 0

	hud_state = "wiz_boilblood"

/spell/targeted/blood_boil/cast(list/targets, mob/user)
	var/mob/living/carbon/human/H = targets[1]
	H.bodytemperature += 40
	if(prob(10))
		to_chat(H,SPAN_WARNING("\The [user] seems to radiate an uncomfortable amount of heat your direction."))
	if(H.bodytemperature > H.getSpeciesOrSynthTemp(HEAT_LEVEL_3)) //Burst into flames
		H.fire_stacks += 50
		H.IgniteMob()

//////////////////////////////////////////////////////

/spell/targeted/galvanization
	tier = HERETIC_TIER_TWO
	name = "Create Ghoul"
	desc = "Resurrects dead target in form of a loyal ghoul. You can only have three ghouls."
	feedback = "CG"
	school = "heretical"

	spell_flags = SELECTABLE

	charge_type = Sp_CHARGES
	charge_max = 3
	invocation = "Di Le Nal Yen Nath!"
	invocation_type = SpI_SHOUT
	range = 1
	hud_state = "heal_revoke"

/spell/targeted/galvanization/cast(list/targets, mob/living/user)
	var/should_wait = 1
	for(var/t in targets)
		var/mob/living/M = t
		M.rejuvenate()
		M.Drain()
		if(M.client) //We've got a dude
			should_wait = 0
			break //Don't need to check anymore.
	if(should_wait)
		addtimer(new Callback(src,PROC_REF(check_for_ghoul),targets), 30 SECONDS)
	else
		return TRUE


/spell/targeted/galvanization/proc/check_for_ghoul(list/targets)
	for(var/t in targets)
		var/mob/M = t
		if(M.client)
			return
	charge_counter += 1
	to_chat(holder,SPAN_NOTICE("You cannot galvanize soulles husk."))

/*
TIER THREE
*/

/spell/targeted/vicissitude
	name = "Vicissitude"
	desc = "Позволяет проводить хирургические операции (в том числе на себе) без необходимых навыков и без инструментов"
	school = "heretical"
	hud_state = "flesh_4"
//	knowledgecost = 3
