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
