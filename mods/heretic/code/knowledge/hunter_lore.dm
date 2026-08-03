/datum/heretic_knowledge_tree_column/hunt
	route = PATH_MOON
	ui_bgr = "node_hunt"
	complexity = "Hard"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Moonhunter spreads corruption through blood and plague.",
		"Choose this path if you want to weaken the crew from within and strike during the hunt.",
	)
	pros = list(
		"Plague mechanics that scale with your progression.",
		"Strong night-hunting and tracking tools.",
		"Can corrupt silicons and organics alike.",
	)
	cons = list(
		"Requires time to spread your influence.",
		"Less direct combat power early on.",
	)
	tips = list(
		"Sacrifices accelerate your plague.",
		"Coordinate infected crew before the final ascension.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_hunt
	knowledge_tier1 = /datum/heretic_knowledge/hunt/blade
	// guaranteed_side_tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	knowledge_tier2 = /datum/heretic_knowledge/hunt/plague
	// guaranteed_side_tier2 =
	robes = /datum/heretic_knowledge/armor/hunt
	knowledge_tier3 = /datum/heretic_knowledge/hunt/huntsman_garb
	// guaranteed_side_tier3 = /datum/heretic_knowledge/spell/crimson_cleave
	blade = /datum/heretic_knowledge/blade_upgrade/hunt
	knowledge_tier4 = /datum/heretic_knowledge/hunt/music_box
	ascension = /datum/heretic_knowledge/ultimate/hunt_final

/datum/heretic_knowledge/limited_amount/starting/base_hunt
	name = "Principle of the Hunt"
	desc = "Opens the Path of Moonhunter. Transmute a knife, circular saw and wood into a Hunter's blade."
	gain_text = "The moon watches. The plague waits. The hunt begins."
	required_atoms = list(
		/obj/item/material/knife = 1,
		/obj/item/circular_saw = 1,
		/obj/item/stack/material/wood = 1,
	)
	result_atoms = list(/obj/item/material/knife/heretic/hunt)
	limit = 3
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/armor/hunt
	name = "Hunter's Garb"
	desc = "Transmute leather, a helmet and armor into hunter's garb."
	required_atoms = list(
		/obj/item/stack/material/leather = 1,
		/obj/item/clothing/head/helmet = 1,
		/obj/item/clothing/suit/armor/vest = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/hunt)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/obj/obj_suit.dmi'
	research_tree_icon_state = "eldritch_armor"

/datum/heretic_knowledge/blade_upgrade/hunt
	name = "Moonlit Edge"
	desc = "Your Hunter's blade inflicts the ravarkanian plague on struck targets."
	gain_text = "The blade carries the sickness of the moon."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/ultimate/hunt_final
	name = "Ascension: Path of Moonhunter"
	desc = "Complete the hunt and ascend under the pale moon."
	announcement_text = "%NAME% has ascended on the Path of Moonhunter!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"
