/// Blade

/obj/item/material/knife/heretic/flesh
	name = "maniac knife"

/obj/item/melee/sickly_blade/flesh

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/flesh

/obj/item/clothing/gloves/forensic/stitcher


/obj/item/grenade/spawnergrenade/blob
	icon = 'icons/mob/blob.dmi'
	icon_state = "core_sample_2"
	spawn_type = /obj/blob/core/secondary
	spawn_amount = 1
	arm_sound = 'sound/effects/blobattack.ogg'

/obj/item/grenade/spawnergrenade/blob/detonate(mob/living/user)
	var/turf/origin = get_turf(src)
	if (origin)
		playsound(origin, 'sound/effects/blobattack.ogg', 100, 1)
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


// Flesh
// Emits a healing aura that affects any heretic summons (excluding the heretic himself)
/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/flesh
	name = "Writhing Embrace"
	desc = "A rotten carcass, or perhaps several, twisted into fleshy polyps, knotted intestines and cracked bone. \
			How one 'wears' this baffles reasonable understanding. It moves when it believes itself unobserved."
	icon_state = "flesh_armor"
	hoodtype = /obj/item/clothing/head/cult_hoodie/eldritch/flesh
	armor = list(
		melee = ARMOR_MELEE_VERY_HIGH,
		bullet = ARMOR_BALLISTIC_SMALL,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_RESISTANT,
		bomb = ARMOR_BOMB_PADDED,
		bio = ARMOR_BIO_SHIELDED
		)
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/healing_aura


/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/flesh/on_robes_gained(mob/living/user)
/*
	healing_aura = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 15, \
		brute_heal = 3, \
		burn_heal = 3, \
		blood_heal = 3, \
		suffocation_heal = 3, \
		stamina_heal = 15, \
		simple_heal = 3, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HERETIC_SUMMON, \
		healing_color = COLOR_RED, \
		self_heal = FALSE, \
	)
*/

/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/flesh/on_robes_lost(mob/user, obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/robes)
	QDEL_NULL(healing_aura)

/*
/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/flesh/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/iteration = 0
	for(var/obj/item/organ/external/limb as anything in victim.get_bodyparts())
		iteration++
		addtimer(new Callback(limb, TYPE_PROC_REF(/obj/item/organ/external, createwound), /datum/wound/cut/flesh), 1 SECONDS * iteration)
 */

/obj/item/clothing/head/cult_hoodie/eldritch/flesh
	icon_state = "flesh_armor"

	// clothing_traits = list(TRAIT_MEDICAL_HUD)
