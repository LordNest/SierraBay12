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
	knowledge_tier1 = /datum/heretic_knowledge/spell/mist_jaunt
	guaranteed_side_tier1 = /datum/heretic_knowledge/vermin_ball
	knowledge_tier2 = /datum/heretic_knowledge/spell/hunter_whistle
	guaranteed_side_tier2 = /datum/heretic_knowledge/rune_carver
	robes = /datum/heretic_knowledge/armor/hunt
	knowledge_tier3 = /datum/heretic_knowledge/limited_amount/music_box
	guaranteed_side_tier3 = /datum/heretic_knowledge/unfathomable_curio
	blade = /datum/heretic_knowledge/blade_upgrade/hunt
	knowledge_tier4 = /datum/heretic_knowledge/spell/adrenaline
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
	eldritch_passive = /datum/status_effect/heretic_passive/hunt

/datum/heretic_knowledge/spell/mist_jaunt
	name = "Step through Mist"
	desc = "Grants you the spell Step through Mist, a spell that lets you phase out of reality, \
		allowing you to traverse a short distance, passing though any walls."
	gain_text = "First Hunter knew how to walk between the planes."
	action_to_add = /spell/targeted/ethereal_jaunt/mist_jaunt
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/spell/hunter_whistle
	name = "Hunter's Whistle"
	desc = "Grants you the spell Hunter's Whistle. This spell allows you to break lights in your vicinity. \
		This spell also blinds silicons and anyone except you with synthetic eyes."
	gain_text = "The hunt does not begin without a signal. If it is not given, even the best hunter will miss."
	action_to_add = /spell/aoe_turf/hunter_whistle
	cost = 2

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

/datum/heretic_knowledge/limited_amount/music_box
	name = "Music Box"
	desc = "Allows you to transmute a corpse and a poppy to create a Voiceless Dead. \
		The corpse does not need to have a soul. \
		Voiceless Dead are mute ghouls and only have 50 health, but can use Bloody Blades effectively. \
		You can only create two at a time."
	gain_text = "I found notes of a dark ritual, unfinished... yet still, I pushed forward."
	required_atoms = list(
		/obj/item/device/taperecorder = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
		/obj/item/reagent_containers/food/snacks/grown/harebell = 1,
	)
	limit = 1
	cost = 2
	result_atoms = /obj/item/bikehorn/music_box
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "grasp_flesh"

/datum/heretic_knowledge/spell/adrenaline
	name = "Hunter's Whistle"
	desc = "Grants you the spell Hunter's Whistle. This spell allows you to break lights in your vicinity. \
		This spell also blinds silicons and anyone except you with synthetic eyes."
	gain_text = "The hunt does not begin without a signal. If it is not given, even the best hunter will miss."
	action_to_add = /spell/targeted/adrenaline
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/ultimate/hunt_final
	name = "Ascension: Path of Moonhunter"
	desc = "Complete the hunt and ascend under the pale moon."
	announcement_text = "%NAME% has ascended on the Path of Moonhunter!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"
