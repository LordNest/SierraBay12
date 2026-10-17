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

/obj/landmark/heretic/riddle
	name = "lock heretic sacrifice landmark"
	for_heretic_path = PATH_RIDDLE

// Rooms for where heretic sacrifices send people.
/datum/map_template/ruin/heretic
	id = "heretic_sacrifice"
	name = "Heretic Sacrificical Space"
	prefix = "mods/antagonists/maps/"
	suffixes = list("heretic_sacrifice.dmm")

/area/map_template/heretic_sacrifice
	name = "\improper Eldrich Gate"
	icon_state = "heretic"
	requires_power = FALSE
	dynamic_lighting = TRUE
	ambience = list('sound/effects/wind/wind_2_1.ogg','sound/effects/wind/wind_2_2.ogg','sound/effects/wind/wind_3_1.ogg','sound/effects/wind/wind_4_1.ogg','sound/effects/wind/wind_4_2.ogg','sound/effects/wind/wind_5_1.ogg')
	sound_env = ASTEROID
	area_flags = AREA_FLAG_NO_MODIFY
	req_access = list(access_heretic)

/area/map_template/heretic_sacrifice/ash //also, the default
	name = "Blasted Gate"

/area/map_template/heretic_sacrifice/void
	name = "Cosmic Void Gate"
	sound_env = SPACE

/area/map_template/heretic_sacrifice/flesh
	name = "Endless Flesh Gate"
	sound_env = STANDARD_STATION

/area/map_template/heretic_sacrifice/hunt
	name = "Moonhunter Gate"
	forced_ambience = list('sound/effects/wind/tundra2.ogg')
	connected_weather_manager = /datum/weather_manager/swamp
	sound_env = FOREST

/area/map_template/heretic_sacrifice/riddle
	name = "Riddle Gate"
	sound_env = PSYCHOTIC

// Flesh arena props
/obj/structure/cocoon
	name = "\improper Pulsating Cocoon"
	icon = 'mods/heretic/icons/obj/flesh.dmi'
	icon_state = "cocoon"
	desc = "Fleshy cocoon, pulsating from inside. Something definetly trying to break free!"

/obj/structure/flesh_structure
	name = "\improper Fleshy Structure"
	icon = 'mods/heretic/icons/obj/flesh.dmi'
	icon_state = "fleshprop"
	desc = "Hideous amalgamation of flesh and bones."

/obj/structure/flesh_structure/Initialize()
	. = ..()
	set_light(6, 2, l_color = COLOR_RED_LIGHT)
	var/state = rand(2)
	if (state)
		icon_state = "[initial(icon_state)]_[state]"

// Hunter's Dream props
/obj/structure/lamppost
	name = "\improper Lamp Post"
	icon = 'mods/heretic/icons/tallstructure.dmi'
	icon_state = "streetlantern1"
	desc = "Lamp post in the middle of nowhere. Only thing you can cling to like a moth."

/obj/structure/lamppost/Initialize()
	. = ..()
	set_light(8, 2, l_color = COLOR_PALE_ORANGE)
