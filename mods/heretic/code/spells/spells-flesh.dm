/*
TIER ONE
*/

/spell/targeted/fleshmend
	name = "Fleshmend"
	desc = "Ценой голода лечит урон, нанесённый владельцу. Может использоваться даже в бессознательном состоянии."
	helptext = "Может быть использован в бессознательном состоянии."
	enhancedtext = "Healing is twice as effective."
	hud_state = "friendly"
	knowledgecost = 1
	icon = 'mods/heretic/icons/heretic_powers.dmi'
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
	name = "Sensory Overload"
	desc = "Воздействие на ЦНС или её подобие заставляет жертву испытывать жуткую агонию, после того, как вы её коснетесь"
	knowledgecost = 1

	range = 1
	max_target = 1

/*
TIER TWO
*/

/spell/targeted/blood_siphon
	name = "Blood Siphon"
	desc = "вытягивает в АоЕ кровь, лечит раны, собирает кровь с пола (привет культ, как вы там?)."
	feedback = "BO"
	school = "transmutation"
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
	name = "Create Ghoul"
	desc = "Призывает дединсайда, который делает других дедаутсайдами. Извините. Переписать."
	feedback = "RK"

	spell_flags = SELECTABLE

	charge_type = Sp_CHARGES
	charge_max = 1
	invocation = "Di Le Nal Yen Nath!"
	invocation_type = SpI_SHOUT
	range = 1
	hud_state = "heal_revoke"

/spell/targeted/galvanization/cast(list/targets, mob/living/user)
	if(alert(user, "Are you sure?", "Alert", "Yes", "No") == "Yes" && alert(user, "Are you ABSOLUTELY SURE?", "Alert", "Absolutely!", "No") == "Absolutely!")
		var/should_wait = 1
		for(var/t in targets)
			var/mob/living/M = t
			M.rejuvenate()
			if(M.client) //We've got a dude
				should_wait = 0
				break //Don't need to check anymore.
		if(should_wait)
			addtimer(new Callback(src,PROC_REF(check_for_revoke),targets), 30 SECONDS)
		else
			return TRUE


/spell/targeted/revoke/proc/check_for_revoke(list/targets)
	for(var/t in targets)
		var/mob/M = t
		if(M.client)
			return
	charge_counter = charge_max
	to_chat(holder,SPAN_NOTICE("\The [src] refreshes as it seems it could not bring back the souls of those you healed."))

/*
TIER THREE
*/

/spell/targeted/vicissitude
	name = "Vicissitude"
	desc = "Позволяет проводить хирургические операции (в том числе на себе) без необходимых навыков и без инструментов"
	helptext = "Боль и иные критические состояния всё ещё не игнорируются"
	enhancedtext = "More frequent escapes."
	ability_icon_state = "flesh_4"
	knowledgecost = 3
	verbpath = /mob/proc/vicissitude

/mob/proc/vicissitude()
	set category = "heretic"
	set name = "Vicissitude"
	set desc = "Perform surgery without anything, but your bare hands."
