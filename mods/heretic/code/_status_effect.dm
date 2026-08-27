/// From /datum/status_effect/proc/on_creation() : (datum/status_effect/effect)
#define COMSIG_LIVING_STATUS_APPLIED "living_status_applied"

/// From /datum/status_effect/proc/Destroy() : (datum/status_effect/effect)
#define COMSIG_LIVING_STATUS_REMOVED "living_status_removed"

///if it allows multiple instances of the effect
#define STATUS_EFFECT_MULTIPLE 0
///if it allows only one, preventing new instances
#define STATUS_EFFECT_UNIQUE 1
///if it allows only one, but new instances replace
#define STATUS_EFFECT_REPLACE 2
/// if it only allows one, and new instances just instead refresh the timer
#define STATUS_EFFECT_REFRESH 3

/// Use in status effect "duration" to make it last forever
#define STATUS_EFFECT_PERMANENT -1
/// Use in status effect "tick_interval" to prevent it from calling tick()
#define STATUS_EFFECT_NO_TICK -1
/// Use in status effect "tick_interval" to guarantee that tick() gets called on every process()
#define STATUS_EFFECT_AUTO_TICK 0

/// Indicates this status effect is an abstract type, ie not instantiated
/// Doesn't actually do anything in practice, primarily just a marker / used in unit tests,
/// so don't worry if your abstract status effect doesn't actually set this
#define STATUS_EFFECT_ID_ABSTRACT "abstract"

///Processing flags - used to define the speed at which the status will work
/// This is fast - 0.2s between ticks (I believe!)
#define STATUS_EFFECT_FAST_PROCESS 0
/// This is slower and better for more intensive status effects - 1s between ticks
#define STATUS_EFFECT_NORMAL_PROCESS 1

/mob/living
	///a list of all status effects the mob has
	var/list/status_effects

/// Status effects are used to apply temporary or permanent effects to mobs.
/// This file contains their code, plus code for applying and removing them.
/datum/status_effect
	/// The ID of the effect. ID is used in adding and removing effects to check for duplicates, among other things.
	var/id = "effect"
	/// This is how long the status effect lasts in deciseconds.
	/// You can put STATUS_EFFECT_PERMANENT (or INFINITY) here for infinite duration.
	var/duration = STATUS_EFFECT_PERMANENT
	/// This is how long between [proc/tick] calls in deciseconds.
	/// This has to be a multiple of the [var/wait] of the subsystem this status effect is running on, which is based on [var/processing_speed].
	/// Putting STATUS_EFFECT_NO_TICK here will stop [proc/tick] calls, and if [var/duration] is STATUS_EFFECT_PERMANENT, it stops processing entirely.
	/// Putting STATUS_EFFECT_AUTO_TICK here will make every subsystem tick call [proc/tick], making the tick interval depend entirely on [var/processing_speed]
	var/tick_interval = 1 SECONDS
	/// The time until the next [proc/tick] call, gets set to [var/tick_interval] after every [proc/tick] call and decrements on every [proc/process] call.
	var/time_until_next_tick
	/// The mob affected by the status effect.
	VAR_FINAL/mob/living/owner
	/// How many of the effect can be on one mob, and/or what happens when you try to add a duplicate.
	var/status_type = STATUS_EFFECT_UNIQUE
	/// If TRUE, we call [proc/on_remove] when owner is deleted. Otherwise, we call [proc/be_replaced].
	var/on_remove_on_mob_delete = FALSE
	/// If TRUE, and we have an alert, we will show a duration on the alert
	var/show_duration = FALSE
	/// Used to define if the status effect should be using SSfastprocess or SSprocessing
	var/processing_speed = STATUS_EFFECT_FAST_PROCESS
	/// Do we self-terminate when a fullheal is called?
	var/remove_on_fullheal = FALSE
	/// A particle effect, for things like embers - Should be set on update_particles()
	VAR_FINAL/obj/effect/abstract/particle_holder/particle_effect

/datum/status_effect/New(list/arguments)
	on_creation(arglist(arguments))

/// Called from New() with any supplied status effect arguments.
/// Not guaranteed to exist by the end.
/// Returning FALSE from on_apply will stop on_creation and self-delete the effect.
/datum/status_effect/proc/on_creation(mob/living/new_owner, ...)
	if(new_owner)
		owner = new_owner
	if(QDELETED(owner) || !on_apply())
		qdel(src)
		return
	if(owner)
		LAZYADD(owner.status_effects, src)

	if(duration == INFINITY)
		// we will optionally allow INFINITY, because i imagine it'll be convenient in some places,
		// but we'll still set it to -1 / STATUS_EFFECT_PERMANENT for proper unified handling
		duration = STATUS_EFFECT_PERMANENT

	if(tick_interval != STATUS_EFFECT_NO_TICK)
		time_until_next_tick = tick_interval

	if(duration != STATUS_EFFECT_PERMANENT || tick_interval != STATUS_EFFECT_NO_TICK) //don't process if we don't care
		start_processing()

	SEND_SIGNAL(owner, COMSIG_LIVING_STATUS_APPLIED, src)
	return TRUE

/datum/status_effect/Destroy()
	stop_processing()
	if(owner)
		LAZYREMOVE(owner.status_effects, src)
		on_remove()
		SEND_SIGNAL(owner, COMSIG_LIVING_STATUS_REMOVED, src)
		owner = null
	return ..()

// Status effect process. Handles adjusting its duration and ticks.
// If you're adding processed effects, put them in [proc/tick]
// instead of extending / overriding the process() proc.
/datum/status_effect/Process(seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(QDELETED(owner))
		qdel(src)
		return

	if (duration != STATUS_EFFECT_PERMANENT)
		duration = max(0, duration - (seconds_per_tick SECONDS)) // doing it first means its more up to date for ticks to read

	if (tick_interval != STATUS_EFFECT_NO_TICK)
		time_until_next_tick = max(0, time_until_next_tick - (seconds_per_tick SECONDS)) // same here

	if(tick_interval == STATUS_EFFECT_AUTO_TICK)
		tick(seconds_per_tick)
	else if(tick_interval != STATUS_EFFECT_NO_TICK && time_until_next_tick <= 0)
		time_until_next_tick = tick_interval // same here as well
		tick(tick_interval / 10)

	if(QDELING(src))
		return // tick deleted us, no need to continue

	if(duration != STATUS_EFFECT_PERMANENT)
		if(duration <= 0)
			qdel(src)
			return

/// Called whenever the effect is applied in on_created
/// Returning FALSE will cause it to delete itself during creation instead.
/datum/status_effect/proc/on_apply()
	return TRUE

/// Gets and formats examine text associated with our status effect.
/// Return 'null' to have no examine text appear (default behavior).
/datum/status_effect/proc/get_examine_text()
	return null

/**
 * Called every tick from process().
 * This is only called of tick_interval is not -1.
 *
 * Note that every tick =/= every processing cycle.
 *
 * * seconds_between_ticks = This is how many SECONDS that elapse between ticks.
 * This is a constant value based upon the initial tick interval set on the status effect.
 * It is similar to seconds_per_tick, from processing itself, but adjusted to the status effect's tick interval.
 */
/datum/status_effect/proc/tick(seconds_between_ticks)
	return

/// Called whenever the buff expires or is removed (qdeleted)
/// Note that at the point this is called, it is out of the
/// owner's status_effects list, but owner is not yet null
/datum/status_effect/proc/on_remove()
	return

/// Called instead of on_remove when a status effect
/// of status_type STATUS_EFFECT_REPLACE is replaced by itself,
/// or when a status effect with on_remove_on_mob_delete
/// set to FALSE has its mob deleted
/datum/status_effect/proc/be_replaced()
	LAZYREMOVE(owner.status_effects, src)
	owner = null
	qdel(src)

/// Called before being fully removed (before on_remove)
/// Returning FALSE will cancel removal
/datum/status_effect/proc/before_remove(...)
	return TRUE

/// Called when a status effect of status_type STATUS_EFFECT_REFRESH
/// has its duration refreshed in apply_status_effect - is passed New() args
/datum/status_effect/proc/refresh(effect, ...)
	duration = initial(duration)

/// Adds nextmove modifier multiplicatively to the owner while applied
/datum/status_effect/proc/nextmove_modifier()
	return 1

/// Adds nextmove adjustment additiviely to the owner while applied
/datum/status_effect/proc/nextmove_adjust()
	return 0


/// Removes [seconds] of duration from the status effect.
/// Returns whether or not the status effect was qdeleted due to running out of duration.
/datum/status_effect/proc/remove_duration(seconds)
	if(duration == STATUS_EFFECT_PERMANENT) // Infinite duration
		return FALSE

	duration -= (seconds SECONDS)
	if(duration <= 0)
		qdel(src)
		return TRUE

	return FALSE

/// Stops ticking. Entirely stops processing if the effect is permanent.
/datum/status_effect/proc/stop_ticking()
	// If we have a set duration, we can't stop processing as duration is also handled in process
	if(duration != STATUS_EFFECT_PERMANENT)
		time_until_next_tick = STATUS_EFFECT_NO_TICK
		return

	// But if we have are permanent, there is no reason to keep processing if we don't tick
	stop_processing()

/// Stops processing, removing it from relevant subsystems
/datum/status_effect/proc/stop_processing()
	switch(processing_speed)
		if(STATUS_EFFECT_FAST_PROCESS)
			STOP_PROCESSING(SSfastprocess, src)
		if(STATUS_EFFECT_NORMAL_PROCESS)
			STOP_PROCESSING(SSprocessing, src)

/// (Re)starts ticking, also (re)starting processing if the effect is permanent
/datum/status_effect/proc/start_ticking()
	// If we have a set duration, we assume we're processing already, so just reset the timer
	if(duration != STATUS_EFFECT_PERMANENT)
		time_until_next_tick = tick_interval
		return

	// But if we are permanent, we probably need to start processing
	start_processing()

/// (Re)starts processing, adding it to relevant subsystems
/datum/status_effect/proc/start_processing()
	switch(processing_speed)
		if(STATUS_EFFECT_FAST_PROCESS)
			START_PROCESSING(SSfastprocess, src)
		if(STATUS_EFFECT_NORMAL_PROCESS)
			START_PROCESSING(SSprocessing, src)



// Status effect helpers for living mobs

/**
 * Applies a given status effect to this mob.
 *
 * new_effect - TYPEPATH of a status effect to apply.
 * Additional status effect arguments can be passed.
 *
 * Returns the instance of the created effected, if successful.
 * Returns 'null' if unsuccessful.
 */
/mob/living/proc/apply_status_effect(datum/status_effect/new_effect, ...)
	RETURN_TYPE(/datum/status_effect)

	var/list/arguments = args.Copy()

	// If the status effect we're applying doesn't allow multiple effects, we need to handle it
	if(initial(new_effect.status_type) != STATUS_EFFECT_MULTIPLE)
		for(var/datum/status_effect/existing_effect as anything in status_effects)
			if(existing_effect.id != initial(new_effect.id))
				continue

			switch(existing_effect.status_type)
				// Multiple are allowed, continue as normal. (Not normally reachable)
				if(STATUS_EFFECT_MULTIPLE)
					break
				// Only one is allowed of this type - early return
				if(STATUS_EFFECT_UNIQUE)
					return
				// Replace the existing instance (deletes it).
				if(STATUS_EFFECT_REPLACE)
					existing_effect.be_replaced()
				// Refresh the existing type, then early return
				if(STATUS_EFFECT_REFRESH)
					existing_effect.refresh(arglist(arguments))
					return

	// For the new effect the 1st argument is this mob
	arguments[1] = src

	// Create the status effect with our mob + our arguments
	var/datum/status_effect/new_instance = new new_effect(arguments)
	if(!QDELETED(new_instance))
		return new_instance

/**
 * Removes all instances of a given status effect from this mob
 *
 * removed_effect - TYPEPATH of a status effect to remove.
 * Additional status effect arguments can be passed - these are passed into before_remove.
 *
 * Returns TRUE if at least one was removed.
 */
/mob/living/proc/remove_status_effect(datum/status_effect/removed_effect, ...)
	var/list/arguments = args.Copy(2)

	. = FALSE
	for(var/datum/status_effect/existing_effect as anything in status_effects)
		if(existing_effect.id == initial(removed_effect.id) && existing_effect.before_remove(arglist(arguments)))
			qdel(existing_effect)
			. = TRUE

	return .

/**
 * Checks if this mob has a status effect that shares the passed effect's ID
 *
 * checked_effect - TYPEPATH of a status effect to check for. Checks for its ID, not its typepath
 *
 * Returns an instance of a status effect, or NULL if none were found.
 */
/mob/proc/has_status_effect(datum/status_effect/checked_effect)
	// Yes I'm being cringe and putting this on the mob level even though status effects only apply to the living level
	// There's quite a few places (namely examine and, bleh, cult code) where it's easier to not need to cast to living before checking
	// for an effect such as blindness
	return null

/mob/living/has_status_effect(datum/status_effect/checked_effect)
	RETURN_TYPE(/datum/status_effect)

	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			return present_effect

	return null

///Gets every status effect of an ID and returns all of them in a list, rather than the individual 'has_status_effect'
/mob/living/proc/get_all_status_effect_of_id(datum/status_effect/checked_effect)
	RETURN_TYPE(/list/datum/status_effect)

	var/list/all_effects_of_type = list()
	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			all_effects_of_type += present_effect

	return all_effects_of_type

/**
 * Returns a list of all status effects that share the passed effect type's ID
 *
 * checked_effect - TYPEPATH of a status effect to check for. Checks for its ID, not its typepath
 *
 * Returns a list
 */
/mob/proc/has_status_effect_list(datum/status_effect/checked_effect)
	// See [/mob/proc/has_status_effect] for reason behind having this on the mob level
	return null

/mob/living/has_status_effect_list(datum/status_effect/checked_effect)
	RETURN_TYPE(/list)

	var/list/effects_found = list()
	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			effects_found += present_effect

	return effects_found
