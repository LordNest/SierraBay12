/*
 * Path column definitions for the four main heretic routes.
 * Full flesh implementation lives in flesh_lore.dm (currently disabled).
 */

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
	// knowledge_tier1 = /datum/heretic_knowledge/riddle/blade
	guaranteed_side_tier1 = /datum/heretic_knowledge/summon/maid_in_mirror
	knowledge_tier2 = /datum/heretic_knowledge/riddle/riddle_of_blood
	guaranteed_side_tier2 = /datum/heretic_knowledge/ether
	robes = /datum/heretic_knowledge/armor/riddle
	knowledge_tier3 = /datum/heretic_knowledge/riddle/pocket_watch
	// guaranteed_side_tier3 =
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
