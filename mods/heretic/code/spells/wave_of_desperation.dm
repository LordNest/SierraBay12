/spell/wave_of_desperation
	name = "Wail of desperation"
	desc = "Tear your bindings in destructive showcase of power, overwhelming your captors in psionic dread."
	school = "transmutation"
	feedback = "ra"
	invocation_type = SpI_EMOTE
	invocation = "conjures a sphere of fire around themselves."
	school = "conjuration"
	spell_flags = NEEDSCLOTHES
	charge_max = 300
	cooldown_min = 100
	level_max = list(Sp_TOTAL = 2, Sp_SPEED = 2, Sp_POWER = 0)
	cast_sound = 'sound/effects/meteorimpact.ogg'
	duration = 40
	hud_state = "gen_immolate"

/spell/wave_of_desperation/choose_targets()
	return list(holder)

/spell/wave_of_desperation/cast(list/targets, mob/user)

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
