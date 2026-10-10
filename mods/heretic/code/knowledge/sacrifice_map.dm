// Some various defines used in the heretic sacrifice map.

/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
GLOBAL_LIST_EMPTY(heretic_sacrifice_landmarks)

/// Lardmarks meant to designate where heretic sacrifices are sent.
/obj/landmark/heretic
	name = "default heretic sacrifice landmark"
	/// What path this landmark is intended for.
	var/for_heretic_path = PATH_START

/obj/landmark/heretic/Initialize(mapload)
	. = ..()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = src

/obj/landmark/heretic/Destroy()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = null
	return ..()

/obj/landmark/heretic/ash
	name = "ash heretic sacrifice landmark"
	for_heretic_path = PATH_ASH

/obj/landmark/heretic/flesh
	name = "flesh heretic sacrifice landmark"
	for_heretic_path = PATH_FLESH

/obj/landmark/heretic/void
	name = "void heretic sacrifice landmark"
	for_heretic_path = PATH_VOID

/obj/landmark/heretic/hunt
	name = "hunter heretic sacrifice landmark"
	for_heretic_path = PATH_MOON

/obj/landmark/heretic/lock
	name = "lock heretic sacrifice landmark"
	for_heretic_path = PATH_RIDDLE

// Rooms for where heretic sacrifices send people.
/datum/map_template/ruin/heretic
	name = "Wizard Base"
	prefix = list("mods/heretic/maps/")
	suffixes = list("heretic_sacrifice.dmm")

/area/map_template/heretic
	name = "\improper Wizard's Den"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 0
	req_access = list(access_syndicate)

/area/centcom/heretic_sacrifice
	name = "Mansus Gate"
	icon_state = "heretic"
	ambience = list('sound/effects/wind/wind_2_1.ogg','sound/effects/wind/wind_2_2.ogg','sound/effects/wind/wind_3_1.ogg','sound/effects/wind/wind_4_1.ogg','sound/effects/wind/wind_4_2.ogg','sound/effects/wind/wind_5_1.ogg')
	sound_env = ASTEROID
	area_flags = AREA_FLAG_NO_MODIFY

/area/centcom/heretic_sacrifice/ash //also, the default
	name = "Mansus Ash Gate"

/area/centcom/heretic_sacrifice/void
	name = "Mansus Void Gate"
	sound_env = SPACE

/area/centcom/heretic_sacrifice/flesh
	name = "Mansus Flesh Gate"
	sound_env = STANDARD_STATION

/area/centcom/heretic_sacrifice/hunt
	name = "Mansus Rust Gate"
	sound_env = FOREST

/area/centcom/heretic_sacrifice/riddle
	name = "Mansus Lock Gate"
	sound_env = PSYCHOTIC
