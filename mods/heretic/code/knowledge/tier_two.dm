/*!
 * Tier 2 knowledge: Defensive tools and curses
 */

/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Greaves Of The Prophet"
	desc = "Allows you to combine a pair of shoes and 2 sheets of titanium or silver into a pair of Armored Greaves, they confer to the user full immunity to slips."
	gain_text = " \
		Gristle churns into joint, a pop, and the fool twists a blackened foot from the \
		jaws of another. At their game for centuries, this mangled tree of limbs twists, \
		thrashing snares buried into snarling gums, seeking to shred the weight of grafted \
		neighbors. Weighed down by lacerated feet, this canopy of rancid idiots ever seeks \
		the undoing of its own bonds. I dread the thought of walking in their wake, but \
		I must press on all the same. Their rhythms keep the feud fresh with indifference \
		to barrier or border. Pulling more into their turmoil as they waltz."
	required_atoms = list(
		/obj/item/clothing/shoes = 1,
		list(/obj/item/stack/sheet/mineral/titanium, /obj/item/stack/sheet/mineral/silver) = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
	drafting_tier = 2

/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Grants you Wave Of Desparation, a spell which can only be cast while restrained. \
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."

	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 2
	drafting_tier = 2

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Allows you to transmute a knife, a shard of glass, and a piece of paper to create a Carving Knife. \
		The Carving Knife allows you to etch difficult to see traps that trigger on heathens who walk overhead. \
		Also makes for a handy throwing weapon."
	gain_text = "Etched, carved... eternal. There is power hidden in everything. I can unveil it! \
		I can carve the monolith to reveal the chains!"
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/material/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "rune_carver"
	drafting_tier = 2

/datum/heretic_knowledge/ether
	name = "Ether Of The Newborn"
	desc = "Transmutes a pool of vomit and a shard into a single use potion, drinking it will remove any sort of abnormality from your body including diseases, traumas and implants \
		on top of restoring it to full health, at the cost of losing consciousness for an entire minute."
	gain_text = "Vision and thought grow hazy as the fumes of this ichor swirl up to meet me. \
		Through the haze, I find myself staring back in relief, or something grossly resembling my visage. \
		It is this wretched thing that I consign to my fate, and whose own that I snatch through the haze of dreams. Fools that we are."
	required_atoms = list(
		/obj/item/material/shard = 1,
		/obj/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "poison_flask"
	drafting_tier = 2
