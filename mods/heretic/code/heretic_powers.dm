
/datum/heretic //stores heretic powers, heretic recharge thingie, heretic sacrificed DNA and heretic ID (for heretic hivemind)
	var/list/sacrificed_languages = list() // Necessary because of set_species stuff
	var/sacrificedcount = 0
	var/hereticsacrificedcount = 0	//Starts at one, because that's us
	var/list/datum/sacrificed_mobs/sacrificed_mobs = list()
	var/hereticID = "heretic"
	var/isabsorbing = 0
	var/knowledgepoints = 15
	var/max_knowledgepoints = 15
	var/list/purchased_powers = list()
	var/list/purchased_organs = list()
	var/already_regenerating = FALSE
	var/mimicing = ""
	var/cloaked = 0
	var/absorbing_lethally = ABSORB_NONLETHAL
	var/tendons_reinforced = FALSE;
	var/list/toxin_victims = list()
	var/armor_deployed = 0 //This is only used for heretic_generic_equip_all_slots() at the moment.
	var/recursive_enhancement = 0 //Used to power up other abilities from the ling power with the same name.
	var/list/purchased_powers_history = list() //Used for round-end report, includes respec uses too.
	var/last_shriek = null // world.time when the ling last used a shriek.
	var/next_escape = 0	// world.time when the ling can next use Escape Restraints
	var/thermal_sight = FALSE	// Is our Vision Augmented? With thermals?
	var/last_human_form = null

//ling creation, add unique organ here
//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_heretic()

	if(!mind)				return
	if(!mind.heretic)	mind.heretic = new /datum/heretic(gender)

	verbs.Add(/datum/heretic/proc/AlchemyTree)
	add_language("cult")

	var/has_core = FALSE
	if(!length(GLOB.powerinstances_h))
		for(var/P in powers)
			GLOB.powerinstances_h += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/heretic/P in GLOB.powerinstances_h)
		if(!P.knowledgecost) // Is it free?
			if(!(P in mind.heretic.purchased_powers)) // Do we not have it already?
				mind.heretic.purchased_powers += P /// Add it.
				mind.heretic.purchasePower(mind, P, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/heretic/P in mind.heretic.purchased_powers)
		if(P.isVerb)
			if(!(P in src.verbs))
				verbs.Add(P.verbpath)
			if(P.make_hud_button)
				if(!src.ability_master)
					src.ability_master = new /obj/screen/movable/ability_master(null, src)
				src.ability_master.add_heretic_ability(
					object_given = src,
					verb_given = P.verbpath,
					name_given = P.name,
					ability_icon_given = P.ability_icon_state,
					arguments = list()
					)

	var/mob/living/carbon/human/H = src
	if(istype(H))
	for(var/obj/item/organ/internal/augment/lingcore/C in H.internal_organs)
		has_core++
	if(has_core == 0 && istype(src,/mob/living/carbon/human))
		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		var/obj/item/organ/internal/augment/core = new /obj/item/organ/internal/augment/lingcore
		core.forceMove(src)
		core.replaced(src, chest)
		core = null
	return 1

//removes our heretic verbs
/mob/proc/remove_heretic_powers()
	if(!mind || !mind.heretic)	return
	for(var/datum/power/heretic/P in mind.heretic.purchased_powers)
		if(P.isVerb)
			verbs.Remove(P.verbpath)
			var/obj/screen/ability/verb_based/heretic/C = ability_master.get_ability_by_PROC_REF(P.verbpath)
			if(C)
				ability_master.remove_ability(C)


//Helper proc. Does all the checks and stuff for us to avoid copypasta
/mob/proc/heretic_power(required_chems=0, required_sacrifices=0, max_knowledge_damage=100, max_stat=0)

	if(!src.mind)		return
	if(!iscarbon(src))	return

	var/datum/heretic/heretic = src.mind.heretic
	if(!heretic)
		to_world_log("[src] has the heretic_transform() verb but is not a heretic.")
		return

	if(src.stat > max_stat)
		to_chat(src, "<span class='warning'>We are incapacitated.</span>")
		return

	if(length(heretic.sacrificed_mobs) < required_sacrifices)
		to_chat(src, "<span class='warning'>We require at least [required_sacrifices] samples of compatible DNA.</span>")
		return

	return heretic

//Used to dump the languages from the heretic datum into the actual mob.
/mob/proc/heretic_update_languages(updated_languages)
	languages = list()
	for(var/language in updated_languages)
		languages += language

	//This isn't strictly necessary but just to be safe...
	add_language("heretic")

//heretic Abilities
/obj/screen/ability/verb_based/heretic
	icon = 'mods/heretic/icons/heretic_powers.dmi'
	icon_state = "const_spell_base"
	background_base_state = "const"

//use this to force add powers
/obj/screen/movable/ability_master/proc/add_heretic_ability(object_given, verb_given, name_given, ability_icon_given, arguments)
	if(!object_given)
		message_admins("ERROR: add_heretic_ability() was not given an object in its arguments.")
	if(!verb_given)
		message_admins("ERROR: add_heretic_ability() was not given a verb/proc in its arguments.")
	if(get_ability_by_PROC_REF(verb_given))
		return // Duplicate
	var/obj/screen/ability/verb_based/heretic/A = new /obj/screen/ability/verb_based/heretic()
	A.ability_master = src
	A.object_used = object_given
	A.verb_to_call = verb_given
	A.ability_icon_state = ability_icon_given
	A.SetName(name_given)
	if(arguments)
		A.arguments_to_use = arguments
	ability_objects.Add(A)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen
