/obj/overmap/visitable/ship/phobos
	name = "SCGF Patrol Craft"
	desc = "SCGF Cobra-class Patrol Craft. Belongs to Third Fleet Battle Group Alpha"
	color = "#81c6ff"
	vessel_mass = 3000 /// Мелкая относительно классов и быстрая
	max_speed = 1/(2 SECONDS)
	place_near_main = list(5, 5)
	initial_generic_waypoints = list(
		"nav_phobos_1",
		"nav_phobos_2",
		"nav_phobos_3",
		"nav_phobos_antag"
	)

#define PHOBOS_PREFIX pick("Theia","Kingfish","Sinai","Fallujah","Montjoie","Dallas","Castro","Quebec","Lee")
/obj/overmap/visitable/ship/phobos/New()
	name = "SFV [PHOBOS_PREFIX], \a [name]"
	for(var/area/ship/patrol/A)
		A.name = "\improper [name] - [A.name]"
		GLOB.using_map.area_purity_test_exempt_areas += A.type
	..()
#undef PHOBOS_PREFIX

/datum/map_template/ruin/away_site/phobos
	name = "Third Fleet Patrol Craft"
	id = "awaysite_phobos"
	description = "SolGov movable small ship with turned humans."
	prefix = "mods/_maps/phobos/maps/"
	suffixes = list("phobos.dmm")
	spawn_cost = 50 // We're testing this
	area_usage_test_exempted_root_areas = list(/area/phobos)

/obj/shuttle_landmark/nav_phobos/nav1
	name = "Ship Navpoint #1"
	landmark_tag = "nav_phobos_1"

/obj/shuttle_landmark/nav_phobos/nav2
	name = "Ship Navpoint #2"
	landmark_tag = "nav_phobos_2"

/obj/shuttle_landmark/nav_phobos/nav3
	name = "Ship Navpoint #3"
	landmark_tag = "nav_phobos_3"

/obj/shuttle_landmark/nav_phobos/nav4
	name = "Ship Navpoint #4"
	landmark_tag = "nav_phobos_antag"
