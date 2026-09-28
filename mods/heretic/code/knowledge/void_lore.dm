// =============================================================================
// Path of Cosmos
// =============================================================================

/datum/heretic_knowledge_tree_column/cosmos
	route = PATH_COSMIC
	ui_bgr = "node_cosmos"
	complexity = "Insane"
	complexity_color = COLOR_PURPLE
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Cosmos draws power from the void between stars.",
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

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmos
	knowledge_tier1 = /datum/heretic_knowledge/cosmos/tier_one
	knowledge_tier2 = /datum/heretic_knowledge/cosmos/tier_two
	robes = /datum/heretic_knowledge/armor/cosmos
	knowledge_tier3 = /datum/heretic_knowledge/cosmos/tier_three
	blade = /datum/heretic_knowledge/blade_upgrade/cosmos
	knowledge_tier4 = /datum/heretic_knowledge/cosmos/tier_four
	ascension = /datum/heretic_knowledge/ultimate/cosmos_final

/datum/heretic_knowledge/limited_amount/starting/base_cosmos
	name = "Principle of the Void"
	desc = "Opens the Path of Cosmos. Transmute glass, a bedsheet and outer clothing into a Void Cloak."
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

/datum/heretic_knowledge/cosmos/tier_one
	name = "Cosmic Whisper"
	desc = "Learn to channel whispers from beyond the veil."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/cosmos/tier_two
	name = "Stellar Transmutation"
	desc = "Transmute star-matter into eldritch tools."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/cosmos/tier_three
	name = "Void Rift"
	desc = "Tear a brief rift in local space-time."
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/cosmos/tier_four
	name = "Cosmic Herald"
	desc = "Summon a herald of the outer dark."
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

/datum/heretic_knowledge/armor/cosmos
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

/datum/heretic_knowledge/blade_upgrade/cosmos
	name = "Void-Touched Steel"
	desc = "Your blade phases through matter on a successful strike."
	gain_text = "Steel from nowhere, gone to nowhere."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/ultimate/cosmos_final
	name = "Ascension: Path of Cosmos"
	desc = "Become one with the infinite void."
	announcement_text = "%NAME% has ascended on the Path of Cosmos!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"
