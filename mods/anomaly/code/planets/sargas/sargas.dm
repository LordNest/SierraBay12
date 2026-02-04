/obj/overmap/visitable/sector/exoplanet/swamp
	name = "Sargas"
	desc = "Planet, covered in vast swamplands and impenetrable swamps that provide both spectacular and dangerous terrain. Its unique ecosystem includes a variety of species of flora and fauna that have adapted to the conditions of such an environment."
	color = "#054515"
	rock_colors = list(COLOR_WHITE)

	possible_themes = list(
		/datum/exoplanet_theme = 100,
		)

	planetary_area = /area/exoplanet/swamp
	map_generators = list(/datum/random_map/noise/exoplanet/swamp)
	ruin_tags_blacklist = RUIN_HABITAT|RUIN_WATER|RUIN_HOT_ANOMALIES|RUIN_ELECTRA_ANOMALIES|RUIN_GRAVI_ANOMALIES|RUIN_CHUDO_ANOMALIES
	surface_color = "#ffffff"
	water_color = "#263908"
	ruin_tags_whitelist = RUIN_SWAMP_BASE
	habitability_weight = HABITABILITY_EXTREME
	has_trees = FALSE
	flora_diversity = 3


/obj/overmap/visitable/sector/exoplanet/swamp/get_atmosphere_color()
	var/air_color = ..()
	return MixColors(COLOR_GRAY20, air_color)



/obj/overmap/visitable/sector/exoplanet/swamp/generate_atmosphere()
	..()
	var/generator/new_temp = generator("num", 250, 300, NORMAL_RAND)
	exterior_atmosphere.temperature = new_temp.Rand()
	exterior_atmosphere.update_values()


/datum/random_map/noise/exoplanet/swamp
	descriptor = "ice exoplanet"
	smoothing_iterations = 5
	land_type = /turf/simulated/floor/exoplanet/grass
	water_type = /turf/simulated/floor/exoplanet/water/shallow //turf/simulated/floor/exoplanet/swamp
	water_level_min = 5
	water_level_max = 6
	fauna_prob = 0
	flora_prob = 0
	large_flora_prob = 0


/area/exoplanet/swamp
	ambience = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')
	base_turf = /turf/simulated/floor/exoplanet/grass

/*
/turf/simulated/floor/exoplanet/swamp
	name = "shallow swamp"
	desc = "Shallow swamp, probably less than a meter deep"

/turf/simulated/floor/exoplanet/swamp/medium
	name = "swamp"
	desc = "Swamp at least a meter deep"

/turf/simulated/floor/exoplanet/swamp/deep
	name = "swale swamp"
	desc = "Deep swamp, the kind that perfectly preserve fossils. Or corpses."
*/
