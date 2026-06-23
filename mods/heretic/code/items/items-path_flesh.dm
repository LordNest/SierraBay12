/// Blade

/obj/item/material/knife/heretic/flesh
	name = "maniac knife"

/obj/item/clothing/gloves/forensic/stitcher

/obj/item/grenade/spawnergrenade/blob

/obj/item/grenade/spawnergrenade/blob/detonate(mob/living/user)
	var/turf/origin = get_turf(src)
	if (origin)
		playsound(origin, 'sound/effects/phasein.ogg', 100, 1)
		for (var/mob/living/living in viewers(origin))
			if (living.eyecheck() < FLASH_PROTECTION_MODERATE)
				living.flash_eyes()
		var/list/spawned = list()
		var/atom/movable/movable
		var/turf/target
		for (var/i = spawn_amount to 1 step -1)
			movable = new spawn_type (origin)
			spawned += movable
			if (spawn_throw_range)
				target = CircularRandomTurfAround(origin, frand(1, spawn_throw_range))
				movable.throw_at(target, spawn_throw_range, 3)
		AfterSpawn(user, spawned)
	qdel(src)

/obj/item/clothing/suit/greatcoat/meat


/obj/item/beartrap/arms
	name = "mechanical trap"
	throw_speed = 2
	throw_range = 1
	gender = PLURAL
	icon = 'icons/obj/beartrap.dmi'
	icon_state = "beartrap0"
	randpixel = 0
	desc = "An amalgamation ."
	throwforce = 0
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_STEEL = 18750)


/obj/item/beartrap/arms/attack_mob(mob/living/L)

	var/target_zone
	if(L.lying)
		target_zone = ran_zone()
	else
		target_zone = pick(BP_L_FOOT, BP_R_FOOT, BP_L_LEG, BP_R_LEG)

	if(!L.apply_damage(30, DAMAGE_BRUTE, target_zone, used_weapon=src))
		return 0

	//trap the victim in place
	if (can_buckle(L))
		set_dir(L.dir)
		buckle_mob(L)
		to_chat(L, SPAN_DANGER("The steel jaws of \the [src] bite into you, trapping you in place!"))
	else
		to_chat(L, SPAN_DANGER("The steel jaws of \the [src] bite into you, but fail to hold you in place!"))
	deployed = 0

/obj/item/beartrap/arms/Crossed(AM as mob|obj)
	if(deployed && isliving(AM))
		var/mob/living/L = AM
		if(!MOVING_DELIBERATELY(L))
			L.visible_message(
				SPAN_DANGER("[L] steps on \the [src]."),
				SPAN_DANGER("You step on \the [src]!"),
				"<b>You hear a loud metallic snap!</b>"
				)
			attack_mob(L)
			if(!buckled_mob)
				anchored = FALSE
			deployed = 0
			update_icon()
	..()
