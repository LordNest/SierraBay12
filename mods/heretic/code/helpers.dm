/datum/action/cooldown
	var/cooldown = 0

/datum/action/cooldown/Activate()

	if(cooldown < world.time)
		return FALSE
	cooldown += world.time + 10 SECONDS

/// Orders heretic knowledge by priority
/proc/cmp_heretic_knowledge(datum/heretic_knowledge/knowledge_a, datum/heretic_knowledge/knowledge_b)
	return initial(knowledge_b.priority) - initial(knowledge_a.priority)

//button for antags to review their descriptions/info
/datum/action/antag_info
	name = "Open Special Role Information"
	button_icon = 'mods/heretic/icons/screen_spells.dmi'
	button_icon_state = "master_closed"

/datum/action/antag_info/New(Target)
	. = ..()
	name = "Open [target] Information"

/datum/action/antag_info/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	target.ui_interact(clicker || owner)

/datum/action/antag_info/IsAvailable(feedback = FALSE)
	if(!target)
		stack_trace("[type] was used without a target antag datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind || !(target in owner.mind.special_role))
		return FALSE
	return TRUE
