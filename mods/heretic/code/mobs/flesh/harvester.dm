/mob/living/simple_animal/hostile/commanded/harvester
	name = "Harvester"
	desc = "A hideous weasel-like creature made of bones and fleshless skin."

	icon = 'icons/mob/simple_animal/animal.dmi'
	icon_state = "diyaab"
	icon_living = "diyaab"
	icon_dead = "diyaab_dead"
	move_to_delay = 1
	maxHealth = 25
	health = 25
	speed = 2
	natural_weapon = /obj/item/natural_weapon/claws
	cold_damage_per_tick = 0
	mob_size = MOB_SMALL
	pass_flags = PASS_FLAG_TABLE
	density = TRUE
	can_escape = TRUE

	ai_holder = /datum/ai_holder/simple_animal/melee/commanded

	response_help = "pets"
	response_harm = "bites"
	response_disarm = "pushes"

	tame_datum = /datum/taming
	diet_type = DIET_OMNIVORE
	preferred_foods = list(/obj/item/reagent_containers/food/snacks/meat)
	tame_difficulty = 0.6

/mob/living/simple_animal/hostile/commanded/harvester/Initialize()
	. = ..()
	if(tame_datum)
		tame_datum.trust = 100
		tame_datum.decay_exempt = TRUE
		tame_datum.named_already = TRUE

/mob/living/simple_animal/hostile/commanded/harvester/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)

	if(!master && istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/S = speaker
		if(isheretic(S))
			master = S
			owner_mob = S
			friends |= weakref(S)
			allowed_targets -= S
			S.guards += src
			if(tame_datum)
				tame_datum.current_tamer = weakref(S)
				tame_datum.named_already = TRUE
	..()

/mob/living/simple_animal/hostile/commanded/harvester/can_use_item(obj/item/O, mob/user)
	if(istype(O, /obj/item/reagent_containers/food/snacks) && stat != DEAD && master)
		// Master gets a direct healing bonus; others get blocked with a growl
		if(user != master)
			visible_message(SPAN_WARNING("\The [src] started to growl"))
			return FALSE
		visible_message(SPAN_NOTICE("\The [user] start feeding the [src] [O]"))
		if(do_after(user, 30, src))
			var/prev_AI_busy = ai_holder.busy
			set_AI_busy(FALSE)
			heal_overall_damage(5, 5)
			qdel(O)
			visible_message(SPAN_NOTICE("\The [src] ate [O]"))
			set_AI_busy(prev_AI_busy)
		return TRUE
	return ..()
