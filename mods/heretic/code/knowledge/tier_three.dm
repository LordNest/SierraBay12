/*!
 * Tier 3 knowledge: Summons
 */

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = "Allows you to transmute five sheets of glass, any suit, and a pair of lungs to create a Maid in the Mirror. \
			Maid in the Mirrors are decent combatants that can become incorporeal by phasing in and out of the mirror realm, serving as powerful scouts and ambushers. \
			Their attacks also apply a stack of void chill."
	gain_text = "Within each reflection, lies a gateway into an unimaginable world of colors never seen and \
		people never met. The ascent is glass, and the walls are knives. Each step is blood, if you do not have a guide."

	required_atoms = list(
		/obj/item/stack/material/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/internal/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/simple_animal/heretic_summon/maid_in_the_mirror
	drafting_tier = 3
