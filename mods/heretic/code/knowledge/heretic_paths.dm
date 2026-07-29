/*
 * Path column definitions for the four main heretic routes.
 * Full flesh implementation lives in flesh_lore.dm (currently disabled).
 */

// =============================================================================
// Path of Flesh (stub — replace with flesh_lore.dm when ready)
// =============================================================================

/datum/heretic_knowledge_tree_column/flesh
	route = PATH_FLESH
	ui_bgr = "node_flesh"
	complexity = "Varies"
	complexity_color = COLOR_ORANGE
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Flesh revolves around flesh, ghouls and biological horrors.",
		"Choose this path if you want minions and body horror.",
	)
	pros = list(
		"Ghoul and flesh-themed transmutations.",
		"Strong support and minion potential.",
	)
	cons = list(
		"Less direct burst damage early on.",
		"Relies on corpses and organic materials.",
	)
	tips = list(
		"Stock up on meat and organs for rituals.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_flesh
	knowledge_tier1 = /datum/heretic_knowledge/flesh/gloves
	knowledge_tier2 = /datum/heretic_knowledge/flesh/fungus
	robes = /datum/heretic_knowledge/armor/flesh
	knowledge_tier3 = /datum/heretic_knowledge/flesh/eyes
	blade = /datum/heretic_knowledge/blade_upgrade/flesh
	knowledge_tier4 = /datum/heretic_knowledge/flesh/coat
	ascension = /datum/heretic_knowledge/ultimate/flesh_final

/datum/heretic_knowledge/limited_amount/starting/base_flesh
	name = "Principle of Hunger"
	desc = "Opens the Path of Flesh. Transmute a knife and blood into stitcher gloves."
	gain_text = "Hundreds starved, but not you... you found strength in hunger."
	required_atoms = list(
		/obj/item/material/knife = 1,
		/obj/decal/cleanable/blood = 1,
	)
	result_atoms = list(/obj/item/clothing/gloves/forensic/stitcher)
	limit = 3
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/armor/flesh
	name = "Flesh Robes"
	desc = "Transmute a table and mask into eldritch robes that act as a focus."
	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/obj/obj_suit.dmi'
	research_tree_icon_state = "eldritch_armor"

/datum/heretic_knowledge/blade_upgrade/flesh
	name = "Bleeding Steel"
	desc = "Your flesh blade causes heavy bleeding on struck targets."
	gain_text = "The flesh remembers every cut."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/ultimate/flesh_final
	name = "Ascension: Path of Flesh"
	desc = "Complete the flesh ritual and ascend."
	announcement_text = "%NAME% has ascended on the Path of Flesh!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

// =============================================================================
// Path of Moonhunter
// =============================================================================

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
	knowledge_tier2 = /datum/heretic_knowledge/hunt/plague
	robes = /datum/heretic_knowledge/armor/hunt
	knowledge_tier3 = /datum/heretic_knowledge/hunt/huntsman_garb
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
	result_atoms = list(/obj/item/storage/backpack/satchel/leather/hunter)
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

// =============================================================================
// Path of Riddle
// =============================================================================

/datum/heretic_knowledge_tree_column/riddle
	route = PATH_RIDDLE
	ui_bgr = "node_riddle"
	complexity = "Medium"
	complexity_color = COLOR_YELLOW
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Riddle trades brute force for tricks, misdirection and situational power.",
		"Choose this path if you enjoy mind games and unconventional solutions.",
	)
	pros = list(
		"Versatile transmutations and trickery.",
		"Strong utility and escape options.",
		"Rewards creative play.",
	)
	cons = list(
		"Weaker in direct confrontation early on.",
		"Requires planning to get full value.",
	)
	tips = list(
		"Save your best tricks for critical moments.",
		"Use misdirection before revealing your hand.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_riddle
	knowledge_tier1 = /datum/heretic_knowledge/riddle/blade
	knowledge_tier2 = /datum/heretic_knowledge/riddle/riddle_of_blood
	robes = /datum/heretic_knowledge/armor/riddle
	knowledge_tier3 = /datum/heretic_knowledge/riddle/pocket_watch
	blade = /datum/heretic_knowledge/blade_upgrade/riddle
	knowledge_tier4 = /datum/heretic_knowledge/riddle/riddle_of_steel
	ascension = /datum/heretic_knowledge/ultimate/riddle_final

/datum/heretic_knowledge/limited_amount/starting/base_riddle
	name = "Principle of the Riddle"
	desc = "Opens the Path of Riddle. Transmute a knife, hatchet and wood into a Vorpal Blade."
	gain_text = "Every question has an answer — and every answer, a price."
	required_atoms = list(
		/obj/item/material/knife = 1,
		/obj/item/material/hatchet = 1,
		/obj/item/stack/material/wood = 1,
	)
	result_atoms = list(/obj/item/material/knife/heretic/riddle)
	limit = 3
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/armor/riddle
	name = "Riddle of Steel"
	desc = "Transmute metal and blood into heavy armor that stops bullets and blades."
	required_atoms = list(/obj/item/stack/material/steel = 3)
	result_atoms = list(/obj/item/clothing/suit/armor/vest)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/obj/obj_suit.dmi'
	research_tree_icon_state = "eldritch_armor"

/datum/heretic_knowledge/blade_upgrade/riddle
	name = "Vorpal Strike"
	desc = "Your Vorpal Blade gains a chance to bypass armor on hit."
	gain_text = "Snicker-snack. The blade finds the gap."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/ultimate/riddle_final
	name = "Ascension: Path of Riddle"
	desc = "Answer the final riddle and ascend beyond reason."
	announcement_text = "%NAME% has ascended on the Path of Riddle!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"

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
