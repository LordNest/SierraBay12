/spell/targeted/flex

	name = "Flex"
	desc = "Рвём наручники, смирительные рубашки, микростаним всех вокруг на 1 секунду."
	helptext = "We can instantly escape from most restraints and bindings, but we cannot do it often."
	enhancedtext = "More frequent escapes."
	ability_icon_state = "flesh_4"
	knowledgecost = 2
	verbpath = /mob/proc/heretic_escape_restraints

//Escape Cuffs. By design this does not escape from straight jackets
/mob/proc/heretic_escape_restraints()
	set category = "heretic"
	set name = "Escape Restraints (40)"
	set desc = "Removes handcuffs and legcuffs instantly."

	var/escape_cooldown = 5 MINUTES		//This is used later to prevent spamming
	var/mob/living/carbon/human/C = src
	var/datum/heretic/heretic = heretic_power(40,0,100,CONSCIOUS)
	if(!heretic)
		return 0
	if(world.time < heretic.next_escape)
		to_chat(src, "<span class='warning'>We are still recovering from our last escape...</span>")
		return 0
	if(!(C.handcuffed || istype(C.wear_suit,/obj/item/clothing/suit/straight_jacket)))	// No need to waste chems if there's nothing to break out of
		to_chat(C, "<span class='warning'>We are are not restrained in a way we can escape...</span>")
		return 0


	to_chat(C,"<span class='notice'>We contort our extremities and slip our cuffs.</span>")
	playsound(src, 'sound/effects/blobattack.ogg', 30, 1)
	if(C.handcuffed)
		var/obj/item/weapon/W = C.handcuffed
		C.unEquip(C.handcuffed)
		//C.handcuffed = null
		if(C.buckled && C.buckled.buckle_require_restraints)
			C.buckled.unbuckle_mob()
		C.drop_from_inventory(C.handcuffed)
		if (C.client)
			C.client.screen -= W
		W.forceMove(C.loc)
		W.dropped(C)
		if(W)
			W.layer = initial(W.layer)
	if(istype(C.wear_suit, /obj/item/clothing/suit/straight_jacket))
		var/obj/item/clothing/suit/straight_jacket/SJ = C.wear_suit
		SJ.forceMove(C.loc)
		SJ.dropped(C)
		C.wear_suit = null
		escape_cooldown *= 1.5	// Straight jackets are tedious compared to cuffs.

	if(src.mind.heretic.recursive_enhancement)
		escape_cooldown *= 0.5

	heretic.next_escape = world.time + escape_cooldown	//And now we set the timer

	return TRUE
