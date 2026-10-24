/datum/heretic_knowledge_tree_column/void
	route = PATH_COSMIC
	ui_bgr = "node_void"
	complexity = "Insane"
	complexity_color = COLOR_NAVY_BLUE
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "void_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Void draws power from the void between stars.",
		"Choose this path for eldritch spells and cosmic horror.",
	)
	pros = list(
		"Powerful void and cosmic magic.",
		"Excellent area control.",
		"Terrifying ascension potential.",
	)
	cons = list(
		"High knowledge costs.",
		"Demands careful resource management.",
	)
	tips = list(
		"Hoard knowledge points for key nodes.",
		"Void rituals work best with preparation.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	knowledge_tier1 = /datum/heretic_knowledge/spell/void_shift
	knowledge_tier2 = /datum/heretic_knowledge/void/tier_two
	robes = /datum/heretic_knowledge/armor/void
	knowledge_tier3 = /datum/heretic_knowledge/rifle
	blade = /datum/heretic_knowledge/blade_upgrade/void
	knowledge_tier4 = /datum/heretic_knowledge/void/tier_four
	ascension = /datum/heretic_knowledge/ultimate/void_final

/datum/heretic_knowledge/limited_amount/starting/base_void
	name = "Principle of the Void"
	desc = "Opens the Path of Void. Transmute glass, a bedsheet and outer clothing into a Void Cloak."
	gain_text = "The void gazes back. You gaze deeper."
	required_atoms = list(
		/obj/item/material/shard = 1,
		/obj/item/bedsheet = 1,
		/obj/item/clothing/suit = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch)
	limit = 1
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/spell/void_shift
	name = "Knitting of Flesh"
	desc = "Grants you the spell Knit Flesh. This spell allows you to remove organs from victims \
		without requiring a lengthy surgery. This process is much longer if the target is not dead. \
		This spell also allows you to heal your minions and summons, or restore failing organs to acceptable status."
	gain_text = "But they were not out of my reach for long. With every step, the screams grew, until at last \
		I learned that they could be silenced."
	action_to_add = /spell/targeted/equip_item/void_shift
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/void/tier_two
	name = "Stellar Transmutation"
	desc = "Transmute star-matter into eldritch tools."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/void/tier_three
	name = "Void Rift"
	desc = "Tear a brief rift in local space-time."
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/void/tier_four
	name = "Cosmic Herald"
	desc = "Summon a herald of the outer dark."
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/armor/void
	name = "Starweave Robes"
	desc = "Transmute a table and mask into cosmic robes that act as a focus."
	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/obj/obj_suit.dmi'
	research_tree_icon_state = "eldritch_armor"

/datum/heretic_knowledge/blade_upgrade/void
	name = "Void-Touched Steel"
	desc = "Your blade phases through matter on a successful strike."
	gain_text = "Steel from nowhere, gone to nowhere."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/ultimate/void_final
	name = "Ascension: Path of Void"
	desc = "Become one with the infinite void."
	announcement_text = "%NAME% has ascended on the Path of Void!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"
