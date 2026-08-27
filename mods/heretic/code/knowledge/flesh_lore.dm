/datum/heretic_knowledge_tree_column/flesh
	route = PATH_FLESH
	ui_bgr = "node_flesh"
	complexity = "Varies"
	complexity_color = COLOR_ORANGE
	icon = list(
		"icon" = 'mods/heretic/icons/khopesh.dmi',
		"state" = "flesh_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Flesh revolves around summoning ghouls and monstrosities to do your bidding.",
		"Pick this path if you enjoy the fantasy of being a necromancer commanding legions of allies.",
	)
	pros = list(
		"Can turn dead humanoids into fragile but loyal ghouls.",
		"Access to a versatile list of summoned minions.",
		"Your summons are very versatie and can quicky overwhelm the crew should you coordinate your attacks",
		"Eating organs or being fat grants various boons (depending on the level of your passive).",
	)
	cons = list(
		"A high degree of your progression is obtaining additional summoned monsters.",
		"You have very little utility beyond your summoned monsters.",
		"You gain no inherent access to defensive, offensive or mobility spells.",
		"You are mostly focused around supporting your minions.",
	)
	tips = list(
		"As a Flesh Heretic, organs and dead bodies are your best friends! You can use them for rituals, to heal or to gain buffs.",
		"Your Flesh Surgery spell can heal your summons. Your robes grant you an aura that also heals nearby summons (but not yourself).",
		"Your Flesh Surgery spell also lets you steal organs from humanoids. Useful if you need a spare liver.",
		"Raw Prophets can link you and other summons in a telepathic network, allowing for long distance co-ordination.",
		"Flesh Stalkers are decent combatants with the ability to disguise themselves as small creatures, like beepskies and corgis. They can also utilize an EMP spell, but this can potentially harm them if they transformed into a robot!",
		"Your success with this path is reliant on how knowledgable or robust your minions are. However, there is always power in numbers; the more minions, the higher your chances of success.",
		"Your minions are more expendable than you are. Do not be afraid to tell them to go to their deaths. You can just recover them later... maybe.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_flesh
	knowledge_tier1 = /datum/heretic_knowledge/limited_amount/flesh_ghoul
	// guaranteed_side_tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	knowledge_tier2 = /datum/heretic_knowledge/spell/flesh_surgery
	guaranteed_side_tier2 = /datum/heretic_knowledge/fungoid_heart // /datum/heretic_knowledge/crucible
	robes = /datum/heretic_knowledge/armor/flesh
	knowledge_tier3 = /datum/heretic_knowledge/summon/raw_prophet
	guaranteed_side_tier3 = /datum/heretic_knowledge/spell/crimson_cleave
	blade = /datum/heretic_knowledge/blade_upgrade/flesh
	knowledge_tier4 = /datum/heretic_knowledge/summon/stalker
	ascension = /datum/heretic_knowledge/ultimate/flesh_final

/datum/heretic_knowledge/limited_amount/starting/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the Path of Flesh to you. \
		Allows you to transmute a knife and a pool of blood into a Bloody Blade. \
		You can only create three at a time."
	gain_text = "Hundreds of us starved, but not me... I found strength in my greed."
	required_atoms = list(
		/obj/item/material/knife = 1,
		/obj/decal/cleanable/blood = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	limit = 3 // Bumped up so they can arm up their ghouls too.
	research_tree_icon_path = 'mods/heretic/icons/khopesh.dmi'
	research_tree_icon_state = "flesh_blade"
	// mark_type = /datum/status_effect/eldritch/flesh
	// eldritch_passive = /datum/status_effect/heretic_passive/flesh

/datum/heretic_knowledge/limited_amount/starting/base_flesh/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
//	var/datum/objective/heretic_summon/summon_objective = new()
//	summon_objective.owner = our_heretic.owner
//	our_heretic.objectives += summon_objective

//	to_chat(user, SPAN_OCCULT("Undertaking the Path of Flesh, you are given another objective."))
//	our_heretic.owner.announce_objectives()

/datum/heretic_knowledge/limited_amount/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to transmute a corpse and a poppy to create a Voiceless Dead. \
		The corpse does not need to have a soul. \
		Voiceless Dead are mute ghouls and only have 50 health, but can use Bloody Blades effectively. \
		You can only create two at a time."
	gain_text = "I found notes of a dark ritual, unfinished... yet still, I pushed forward."
	required_atoms = list(
		/mob/living/carbon/human = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	limit = 2
	cost = 2
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "ghoul_voiceless"

/datum/heretic_knowledge/limited_amount/flesh_ghoul/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(MUTATION_HUSK in body.mutations)
			to_chat(user, SPAN_OCCULT("[body] is not in a valid state to be made into a ghoul."))
			continue

		// We'll select any valid bodies here. If they're clientless, we'll give them a new one.
		selected_atoms += body
		return TRUE

	loc.visible_message(user, "ritual failed, no valid body!")
	return FALSE

/datum/heretic_knowledge/limited_amount/flesh_ghoul/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.visible_message(user, "ritual failed, no valid body!")
		return FALSE


	for(var/mob/observer/G in GLOB.dead_mobs)
		if(G.mind && G.mind.current == soon_to_be_ghoul && G.client)
			to_chat(G, SPAN_NOTICE("<font size = 3><b>Your body has been revived, <b>Re-Enter Corpse</b> to return to it.</b></font>"))
			break

	// addtimer(new Callback(src,PROC_REF(check_for_revoke),targets), 20 SECONDS)
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		log_and_message_admins("[user] is creating a ghoul of a body with no player.")
		// loc.visible_message(user, "ritual failed, no ghost within the body!")
		// return FALSE
		var/datum/ghosttrap/T = get_ghost_trap("heretic ghoul")
		T.request_player(src, "A heretic's ghoul needs player.")
		if(!soon_to_be_ghoul.key)
			loc.visible_message(user, "ritual failed, no ghosts!")
			return FALSE
		else
			log_and_message_admins("[key_name_admin(soon_to_be_ghoul.key)] has taken control of ([key_name_admin(soon_to_be_ghoul)] to replace an AFK player.")

	selected_atoms -= soon_to_be_ghoul
	make_ghoul(user, soon_to_be_ghoul)
	return TRUE

/// Makes [victim] into a ghoul.
/datum/heretic_knowledge/limited_amount/flesh_ghoul/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	log_and_message_admins("[key_name_admin(user)] created a voiceless dead, [key_name_admin(victim)].")
	if(victim.is_species(SPECIES_IPC) || victim.is_species(SPECIES_ADHERENT) || BP_IS_ROBOTIC(victim.organs_by_name[BP_CHEST]))
		to_chat(victim, SPAN_DANGER("Suddenly you found yourself in new world full of PAIN!"))
		victim.set_species(SPECIES_MOTH) // TO DO: KILL MOTH
		alert(victim, "Ты теперь подчинен воле [user], служи ему слепо и верно, пока он не скажет обратного.", "Ты был порабощен")
		GLOB.thralls.add_antagonist(victim.mind, new_controller = user)
		return TRUE
	else
		victim.basic_revival()
		victim.Drain()
		alert(victim, "Ты теперь подчинен воле [user], служи ему слепо и верно, пока он не скажет обратного.", "Ты был порабощен")
		GLOB.thralls.add_antagonist(victim.mind, new_controller = user)
		return TRUE

/datum/heretic_knowledge/spell/flesh_surgery
	name = "Knitting of Flesh"
	desc = "Grants you the spell Knit Flesh. This spell allows you to remove organs from victims \
		without requiring a lengthy surgery. This process is much longer if the target is not dead. \
		This spell also allows you to heal your minions and summons, or restore failing organs to acceptable status."
	gain_text = "But they were not out of my reach for long. With every step, the screams grew, until at last \
		I learned that they could be silenced."
	action_to_add = /spell/targeted/equip_item/flesh_surgery
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/armor/flesh
	desc = "Allows you to transmute a table (or a suit), a mask and a pool of blood to create a writhing embrace. \
		It grants you the ability to detect the health condition of other living (and non-living) and an aura that slowly heals your summons. \
		Acts as a focus while hooded."
	gain_text = "I tugged these wretched, slothing things about me, like one might a warm blanket. \
				With eyes-not-mine, they will witness. With teeth-not-mine, they will clench. With limbs-not-mine, they will break."
	result_atoms = list(/obj/item/clothing/suit/storage/hooded/cultrobes/eldritch/flesh)
	research_tree_icon_state = "flesh_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/decal/cleanable/blood = 1,
	)

/datum/heretic_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	desc = "Allows you to transmute a pair of eyes, a left arm, and a pool of blood to create a Raw Prophet. \
		Raw Prophets have a greatly increased sight range and x-ray vision, as well as a long range jaunt and \
		the ability to link minds to communicate with ease, but are very fragile and weak in combat."
	gain_text = "I could not continue alone. I was able to summon The Uncanny Man to help me see more. \
		The screams... once constant, now silenced by their wretched appearance. Nothing was out of reach."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/decal/cleanable/blood = 1,
		/obj/item/organ/external/arm = 1,
	)
//	mob_to_summon = /mob/living/basic/heretic_summon/raw_prophet
	cost = 2


/datum/heretic_knowledge/blade_upgrade/flesh
	name = "Bleeding Steel"
	desc = "Your Bloody Blade now causes enemies to bleed heavily on attack."
	gain_text = "The Uncanny Man was not alone. They led me to the Marshal. \
		I finally began to understand. And then, blood rained from the heavens."
	research_tree_icon_path = 'mods/heretic/icons/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_flesh"
	///What type of wound do we apply on hit
//	var/wound_type = /datum/wound/slash/flesh/severe

///datum/heretic_knowledge/blade_upgrade/flesh/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
//	if(!iscarbon(target) || source == target)
//		return

//	var/mob/living/carbon/carbon_target = target
//	var/obj/item/organ/external/bodypart = pick(carbon_target.get_bodyparts())
//	var/datum/wound/crit_wound = new wound_type()
//	crit_wound.apply_wound(bodypart, attack_direction = get_dir(source, target))

/datum/heretic_knowledge/summon/stalker
	name = "Lonely Ritual"
	desc = "Allows you to transmute a tail of any kind, a stomach, a tongue, a pen and a piece of paper to create a Stalker. \
		Stalkers can jaunt, release EMPs, shapeshift into animals or automatons, and are strong in combat."
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast I had never seen before. \
		An ever shapeshifting mass of flesh, it knew well my goals. The Marshal approved."

	required_atoms = list(
		//obj/item/organ/internal/tail = 1,
		/obj/item/organ/internal/stomach = 1,
		//obj/item/organ/internal/tongue = 1,
		/obj/item/pen = 1,
		/obj/item/paper = 1,
	)
//	mob_to_summon = /mob/living/basic/heretic_summon/stalker
	cost = 2

	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/flesh_final
	name = "Priest's Final Hymn"
	desc = "The ascension ritual of the Path of Flesh. \
		Bring 4 corpses to a transmutation rune to complete the ritual. \
		When completed, you gain the ability to shed your human form \
		and become the Lord of the Night, a supremely powerful creature. \
		Just the act of transforming causes nearby heathens great fear and trauma. \
		While in the Lord of the Night form, you can consume arms to heal and regain segments. \
		Additionally, you can summon three times as many Ghouls and Voiceless Dead, \
		and can create unlimited blades to arm them all."
	gain_text = "With the Marshal's knowledge, my power had peaked. The throne was open to claim. \
		Men of this world, hear me, for the time has come! The Marshal guides my army! \
		Reality will bend to THE LORD OF THE NIGHT or be unraveled! WITNESS MY ASCENSION!"
	required_atoms = list(/mob/living/carbon/human = 4)
	announcement_text = "%SPOOKY% Ever coiling vortex. Reality unfolded. ARMS OUTREACHED, THE LORD OF THE NIGHT, %NAME% has ascended! Fear the ever twisting hand! %SPOOKY%"
//	announcement_sound = 'sound/music/antag/heretic/ascend_flesh.ogg'

/datum/heretic_knowledge/ultimate/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
//	var/datum/action/cooldown/spell/shapeshift/shed_human_form/worm_spell = new(user.mind)
//	worm_spell.Grant(user)

	var/datum/antagonist/heretic/heretic_datum = isheretic(user)
	var/datum/heretic_knowledge/limited_amount/starting/base_flesh/grasp_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_flesh)
	grasp_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/flesh_ghoul)
	ritual_ghoul.limit *= 3
	var/datum/heretic_knowledge/limited_amount/starting/base_flesh/blade_ritual = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_flesh)
	blade_ritual.limit = 999
