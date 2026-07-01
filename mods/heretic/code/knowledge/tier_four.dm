/*!
 * Tier 4 knowledge: Combat related knowledge
 */

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Grants you Space Phase, a spell that allows you to move freely through space. \
		You can only phase in and out when you are on a space or misc turf."
	gain_text = "You feel like your body can move through space as if you where dust."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 2
	research_tree_icon_frame = 6
	drafting_tier = 4

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, lungs, and any belt into an Unfathomable Curio - \
			a belt that can hold blades and items for rituals. Whilst worn it will veil you, \
			blocking one blow of incoming damage, at the cost of the veil. The veil will recharge itself out of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."

	required_atoms = list(
		/obj/item/organ/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"
	drafting_tier = 4

/datum/heretic_knowledge/rust_sower
	name = "Rust Sower Grenade"
	desc = "Allows you to combine a chemical grenade casing and some moldy food to conjure a cursed grenade filled with Eldritch Rust, upon detonating it releases a huge cloud that blinds organics, rusts affected turfs and obliterates Silicons and Mechs."
	gain_text = "The choked vines of the Rusted Hills are burdened with such overripe fruits. It undoes the markers of progress, leaving a clean slate to work into new shapes."
	required_atoms = list(
		list(
			/obj/item/food/breadslice/moldy,
			/obj/item/food/badrecipe/moldy,
			/obj/item/food/deadmouse/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/boiledegg/rotten,
			/obj/item/food/egg/rotten
		) = 1,
		/obj/item/grenade/chem_grenade = 1
	)
	result_atoms = list(/obj/item/grenade/chem_grenade/rust_sower)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/grenade.dmi'
	research_tree_icon_state = "rustgrenade"
	drafting_tier = 4

/datum/heretic_knowledge/spell/crimson_cleave
	name = "Crimson Cleave"
	desc = "Grants you Crimson Cleave, a targeted spell which siphons health in a small AOE. Cleanses all wounds upon casting"
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
				told me to use them regardless. Soon, he said, I would know them well."
	action_to_add = /datum/action/cooldown/spell/pointed/crimson_cleave
	cost = 2
	drafting_tier = 4
