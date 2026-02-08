/spell/targeted/flex

	name = "Flex"
	desc = "Рвём наручники, смирительные рубашки, микростаним всех вокруг на 1 секунду."
	hud_state = "flesh_4"
//	knowledgecost = 2

//Escape Cuffs. By design this does not escape from straight jackets

/spell/targeted/flex/cast(list/targets, mob/user)

	var/escape_cooldown = 5 MINUTES		//This is used later to prevent spamming
	var/mob/living/carbon/human/C = src

	if(world.time < escape_cooldown)
		to_chat(src, "<span class='warning'>We are still recovering from our last escape...</span>")
		return FALSE
	if(!(C.handcuffed || istype(C.wear_suit,/obj/item/clothing/suit/straight_jacket)))	// No need to waste chems if there's nothing to break out of
		to_chat(C, "<span class='warning'>We are are not restrained in a way we can escape...</span>")
		return FALSE

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

	return TRUE
