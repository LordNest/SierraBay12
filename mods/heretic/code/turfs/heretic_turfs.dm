/singleton/flooring/grass/cold
	name = "grass"
	desc = "Do they smoke grass out in space, Bowie? Or do they smoke AstroTurf?"
	icon = 'mods/heretic/icons/turfs/coldgrass.dmi'
	icon_base = "grass"
	has_base_range = 3
	damage_temperature = T0C+80
	flags = TURF_HAS_EDGES | TURF_HAS_CORNERS | TURF_REMOVE_SHOVEL
	build_type = null
	can_engrave = FALSE
	floor_smooth = SMOOTH_NONE
	wall_smooth = SMOOTH_ALL
	space_smooth = SMOOTH_NONE

/singleton/flooring/grass/cold/snow

/obj/item/stack/tile/grass/cold

/turf/simulated/floor/grass/cold
	name = "grass patch"
	icon = 'mods/heretic/icons/turfs/coldgrass.dmi'
	icon_state = "grass0"
	initial_flooring = /singleton/flooring/grass/cold
	temperature = 277.15

/turf/simulated/floor/grass/cold/snow
	name = "grass patch"
	icon = 'mods/heretic/icons/turfs/snowgrass.dmi'
	icon_state = "grass0"
	initial_flooring = /singleton/flooring/grass/cold/snow

/turf/simulated/wall/flesh
	icon_state = "flesh"
	icon = 'mods/heretic/icons/turfs/flesh.dmi'

/turf/simulated/floor/flesh
	name = "engraved floor"
	icon = 'mods/heretic/icons/turfs/flesh.dmi'
	icon_state = "floor"
	initial_flooring = /singleton/flooring/reinforced/flesh

/singleton/flooring/reinforced/flesh
	name = "engraved floor"
	desc = "Unsettling whispers waver from the surface..."
	icon = 'mods/heretic/icons/turfs/flesh.dmi'
	icon_base = "floor"
	build_type = null
	has_damage_range = 6
	flags = TURF_ACID_IMMUNE
	can_paint = null
