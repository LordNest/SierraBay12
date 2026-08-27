/datum/action/datumized
	action_type = AB_GENERIC
	var/cooldown = 0
	/// Set in New() via the proc link_to(). PLEASE set a target if you're making an action
	var/datum/target_datum

/datum/action/datumized/New(Target)
	link_to(Target)

/// Links the passed target to our action, registering any relevant signals
/datum/action/datumized/proc/link_to(Target)
	target_datum = Target
	RegisterSignal(target_datum, COMSIG_QDELETING, PROC_REF(clear_ref), override = TRUE)

/// Signal proc that clears any references based on the owner or target deleting
/// If the owner's deleted, we will simply remove from them, but if the target's deleted, we will self-delete
/datum/action/datumized/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == target_datum)
		qdel(src)

/datum/action/datumized/cooldown/Activate()

	if(cooldown < world.time)
		return FALSE
	cooldown += world.time + 10 SECONDS

/// Orders heretic knowledge by priority
/proc/cmp_heretic_knowledge(datum/heretic_knowledge/knowledge_a, datum/heretic_knowledge/knowledge_b)
	return initial(knowledge_b.priority) - initial(knowledge_a.priority)

//button for antags to review their descriptions/info
/datum/action/datumized/antag_info
	name = "Open Special Role Information"
	button_icon = 'mods/heretic/icons/screen_spells.dmi'
	button_icon_state = "master_closed"

/datum/action/datumized/antag_info/New(Target)
	. = ..()
	name = "Open [target_datum] Information"

/datum/action/datumized/antag_info/Trigger()
	. = ..()
	target_datum.ui_interact(owner)

/datum/action/datumized/antag_info/IsAvailable(feedback = FALSE)
	if(!target_datum)
		stack_trace("[type] was used without a target antag datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind)
		return FALSE
	return TRUE

// Yep, our own door access
var/global/const/access_heretic = "ACCESS_HERETIC"
/datum/access/heretic
	id = access_heretic
	desc = "Heretic"
	region = ACCESS_REGION_NONE

/*
Spell zone
*/
/obj/item/spell
	name = "focused energy"
	desc = "A concentrated beam of energy in your hand."
	anchored = TRUE    // Never spawned outside of inventory, should be fine.
	canremove = FALSE // You can use it while prone. Still deleted if the arm is destroyed.
	w_class = ITEM_SIZE_TINY //technically it's just energy or something, I dunno
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_BLOOD
	var/mob/living/carbon/human/creator
	var/range = 1

/obj/item/spell/Process()
	if (creator.handcuffed || (creator.stat != CONSCIOUS))
		QDEL_IN(src, 0)

	if (!creator || loc != creator || !creator.IsHolding(src))
		// Tidy up a bit.
		if(istype(loc,/mob/living))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		QDEL_IN(src, 0)


/obj/item/spell/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/spell/dropped()
	..()
	QDEL_IN(src, 0)

/obj/item/spell/proc/do_spell_effect(atom/target, mob/user)
	return

/obj/item/spell/use_before(atom/target, mob/living/user, click_parameters)
	. = ..()
	var/distance = get_dist(user, target)
	if(distance > range)
		user.visible_message(SPAN_WARNING("Can't reach target without spell range!"))
		return FALSE
	else
		do_spell_effect(target, user)
		QDEL_IN(src, 0)
		return TRUE

/spell/cast_check(skipcharge = 0,mob/user = usr, list/targets) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell

	if(silenced > 0)
		return 0

	if(!(src in user.mind.learned_spells) && holder == user && !(isanimal(user)))
		error("[user] utilized the spell '[src]' without having it.")
		to_chat(user, SPAN_WARNING("You shouldn't have this spell! Something's wrong."))
		return 0

	var/spell_leech = user.disrupts_psionics()
	if(spell_leech)
		to_chat(user, SPAN_WARNING("You try to marshal your energy, but find it leeched away by \the [spell_leech]!"))
		return 0

	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		to_chat(user, SPAN_WARNING("You cannot cast spells in null space!"))

	if((spell_flags & Z2NOCAST) && (user_turf.z in GLOB.using_map.admin_levels)) //Certain spells are not allowed on the centcomm zlevel
		return 0

	if(spell_flags & CONSTRUCT_CHECK)
		for(var/turf/T in range(holder, 1))
			if(findNullRod(T))
				return 0

	if(!src.check_charge(skipcharge, user)) //sees if we can cast based on charges alone
		return 0

	if(holder == user)
		if(istype(user, /mob/living/simple_animal))
			var/mob/living/simple_animal/SA = user
			if(SA.purge)
				to_chat(SA, SPAN_WARNING("The null sceptre's power interferes with your own!"))
				return FALSE

		if(!(spell_flags & GHOSTCAST))
			if(!(spell_flags & NO_SOMATIC))
				var/mob/living/L = user
				if(L.incapacitated(INCAPACITATION_STUNNED|INCAPACITATION_RESTRAINED|INCAPACITATION_BUCKLED_FULLY|INCAPACITATION_FORCELYING|INCAPACITATION_KNOCKOUT))
					to_chat(user, SPAN_WARNING("You can't cast spells while incapacitated!"))
					return FALSE

			if(ishuman(user) && !(invocation_type in list(SpI_EMOTE, SpI_NONE)))
				if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
					to_chat(user, "Mmmf mrrfff!")
					return FALSE

		var/spell/noclothes/spell = locate() in user.mind.learned_spells
		if((spell_flags & NEEDSCLOTHES) && !(spell && istype(spell)))//clothes check
			if(!user.wearing_wiz_garb())
				return FALSE
		if((spell_flags & NEEDSFOCUS) && !(spell && istype(spell)))//clothes check
			if(!user.wearing_focus())
				return FALSE
	return TRUE

/obj/item/clothing/var/heretic_focus = FALSE

// Does this clothing slot count as wizard garb? (Combines a few checks)
/proc/is_heretic_focus(obj/item/clothing/C)
	return istype(C) && C.heretic_focus

/mob/proc/wearing_focus()
	to_chat(src, "Silly creature, you're not a human. Only humans can cast this spell.")
	return FALSE

/mob/living/carbon/human/wearing_focus()
	if(is_heretic_focus(src.wear_suit) && (src.species.hud || (slot_wear_suit in src.species.hud.equip_slots)))
		return TRUE
	else if(is_heretic_focus(get_active_hand(src)) || is_heretic_focus(get_inactive_hand(src)))
		return TRUE
	else if(is_heretic_focus(src.head) && (species.hud || (slot_head in src.species.hud.equip_slots)))
		return TRUE
	else
		to_chat(src, SPAN_WARNING("I need focus to cast that spell."))
		return FALSE
