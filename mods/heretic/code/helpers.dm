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
