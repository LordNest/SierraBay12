/datum/heretic_knowledge_tree_column/riddle
	route = PATH_RIDDLE
	ui_bgr = "node_riddle"
	complexity = "Medium"
	complexity_color = COLOR_YELLOW
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "key_blade",
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
	knowledge_tier1 = /datum/heretic_knowledge/key_ring
	guaranteed_side_tier1 = /datum/heretic_knowledge/summon/maid_in_mirror
	knowledge_tier2 = /datum/heretic_knowledge/spell/butterflies
	guaranteed_side_tier2 = /datum/heretic_knowledge/ether
	robes = /datum/heretic_knowledge/armor/riddle
	knowledge_tier3 = /datum/heretic_knowledge/blood_vial
	guaranteed_side_tier3 = /datum/heretic_knowledge/unfathomable_curio
	blade = /datum/heretic_knowledge/blade_upgrade/riddle
	knowledge_tier4 = /datum/heretic_knowledge/sandglass
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

/datum/heretic_knowledge/key_ring
	name = "Key Keeper's Burden"
	desc = "Enchants an ID card into an Eldritch Card.<br>\
		Hit a pair of airlocks with it to create a pair of portals, \
		which will teleport you between them, but teleport non-heretics randomly. \
		You can ctrl-click the card to invert this behavior for created portals. \
		Each card may only sustain a single pair of portals at the same time.<br>\
		It also functions and appears the same as a regular ID Card. \
		Attacking it with a normal ID card consumes it and gains its access, \
		and you can use it in-hand to change its appearance to a card you fused."
	// transmute_text = "Transmute a wallet, an iron rod, and an ID card."
	gain_text = "The Keeper sneered. \"These plastic rectangles are a mockery of keys, and I curse every door that desires them.\""
	required_atoms = list(
		/obj/item/storage/wallet = 1,
		/obj/item/stack/material/rods = 1,
		/obj/item/card/id = 1,
	)
	result_atoms = list(/obj/item/card/id/heretic)
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "grasp_lock"

/datum/heretic_knowledge/key_ring/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/item/card/id = locate(/obj/item/card/id) in selected_atoms
	if(isnull(id))
		return FALSE
	var/obj/item/card/id/heretic/result_item = new(loc)
	if(!istype(result_item))
		return FALSE
	selected_atoms -= id
	result_item.eat_card(id)
	result_item.shapeshift(id)
	return TRUE

/datum/heretic_knowledge/spell/butterflies
	name = "Trail of Butterflies"
	desc = "Grants you Trail of Butterflies, a spell which dramatically increase your movement speed \
		in cost of granting you clumsy, making you unable to use weapons during it's duration."
	gain_text = "What was first: beauty of butterfly or one, who was able to fully appreciate it?"

	action_to_add = /spell/wave_of_desperation
	cost = 2
	drafting_tier = 2

/datum/heretic_knowledge/armor/riddle
	name = "Riddle of Steel"
	desc = "Transmute metal and blood into heavy armor that stops bullets and blades."
	required_atoms = list(/obj/item/stack/material/steel = 3)
	result_atoms = list(/obj/item/clothing/suit/armor/vest)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/obj/obj_suit.dmi'
	research_tree_icon_state = "eldritch_armor"

/datum/heretic_knowledge/blood_vial
	name = "Riddle of Blood"
	desc = "Transmutes a pool of blood and a shard into a single use potion, drinking it will transmute you into perfect copy of one, \
		which blood was used in the ritual."
	gain_text = "Vision and thought grow hazy as the fumes of this ichor swirl up to meet me. \
		Through the haze, I find myself staring back in relief, or something grossly resembling my visage. \
		It is this wretched thing that I consign to my fate, and whose own that I snatch through the haze of dreams. Fools that we are."
	required_atoms = list(
		/obj/item/material/shard = 1,
		/obj/decal/cleanable/blood = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"
	drafting_tier = 2

//datum/heretic_knowledge/blood_vial/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
//	. = ..()
//	for(var/obj/decal/cleanable/blood in atoms)

/datum/heretic_knowledge/blade_upgrade/riddle
	name = "Vorpal Strike"
	desc = "Your Vorpal Blade gains a chance to bypass armor on hit."
	gain_text = "Snicker-snack. The blade finds the gap."
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"

/datum/heretic_knowledge/sandglass
	name = "Sandglass of Doom"
	desc = "Allows you to transmute 3 rods, lungs, and any belt into an Unfathomable Curio - \
			a belt that can hold blades and items for rituals. Whilst worn it will veil you, \
			blocking one blow of incoming damage, at the cost of the veil. The veil will recharge itself out of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."

	required_atoms = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/stack/material/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "ghoul_voiceless"
	drafting_tier = 4

/datum/heretic_knowledge/ultimate/riddle_final
	name = "Ascension: Path of Riddle"
	desc = "Answer the final riddle and ascend beyond reason."
	announcement_text = "%NAME% has ascended on the Path of Riddle!"
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	research_tree_icon_state = "eye"
