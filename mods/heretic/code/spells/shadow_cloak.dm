/spell/shadow_cloak
	name = "Cloak of Shadow"
	desc = "Completely conceals your identity, but does not make you invisible.  Can be activated early to disable it. \
		While cloaked, you move faster, but undergo actions much slower. \
		Taking damage while cloaked may cause it to lift suddenly, causing negative effects. "
	school = "heretical"
	feedback = "ra"
	invocation_type = SpI_EMOTE
	invocation = "conjures a cloak of shadows around themselves."
	spell_flags = NEEDSFOCUS | HERETIC_CHECK
	charge_max = 6 SECONDS
	cooldown_min = 6 SECONDS
	cast_sound = 'mods/heretic/sound/curse2.ogg'
	duration = 60
	hud_state = "invisibility"

	/// How long before we automatically uncloak?
	var/uncloak_time = 3 MINUTES
	/// A timer id, for the uncloak timer
	var/uncloak_timer
	/// The cloak currently active
	var/datum/status_effect/shadow_cloak/active_cloak

/spell/shadow_cloak/choose_targets()
	return list(holder)

/spell/shadow_cloak/cast(list/targets, mob/user)
	. = ..()
	if(active_cloak)
		uncloak_mob(user)
	else
		uncloak_timer = addtimer(new Callback(src, PROC_REF(timed_uncloak), user), uncloak_time, TIMER_STOPPABLE)
		cloak_mob(user)

/spell/shadow_cloak/proc/timed_uncloak(mob/living/user)
	if(QDELETED(src) || QDELETED(user))
		return

	uncloak_mob(user)

/spell/shadow_cloak/proc/cloak_mob(mob/living/user)
	// playsound(user, 'sound/effects/chemistry/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)
	user.visible_message(
		SPAN_WARNING("[user] disappears into the shadows!"),
		SPAN_NOTICE("You disappear into the shadows, becoming unidentifiable."),
	)

	active_cloak = user.apply_status_effect(/datum/status_effect/shadow_cloak)
	RegisterSignal(active_cloak, COMSIG_QDELETING, PROC_REF(on_early_cloak_loss))

/spell/shadow_cloak/proc/uncloak_mob(mob/living/user, show_message = TRUE)
	if(!QDELETED(active_cloak))
		UnregisterSignal(active_cloak, COMSIG_QDELETING)
		qdel(active_cloak)
	active_cloak = null

	playsound(user, 'mods/heretic/sound/curseattack.ogg', 50)
	if(show_message)
		user.visible_message(
			SPAN_WARNING("[user] appears from the shadows!"),
			SPAN_NOTICE("You appear from the shadows, identifiable once more."),
		)

	// Clear up the timer
	deltimer(uncloak_timer)
	uncloak_timer = null

/// Signal proc for [COMSIG_QDELETING], if our cloak is deleted early, impart negative effects
/spell/shadow_cloak/proc/on_early_cloak_loss(datum/status_effect/source)
	SIGNAL_HANDLER

	var/mob/living/removed = source.owner
	uncloak_mob(removed, show_message = FALSE)
	removed.visible_message(
		SPAN_WARNING("[removed] is pulled from the shadows!"),
		SPAN_DANGER("You are pulled out of the shadows!"),
	)

	// StartCooldown(uncloak_time)

/// Shadow cloak effect. Conceals the owner in a cloud of purple smoke, making them unidentifiable.
/// Also comes with some other buffs and debuffs - faster movespeed, slower actionspeed, etc.
/datum/status_effect/shadow_cloak
	id = "shadow_cloak"
	tick_interval = STATUS_EFFECT_NO_TICK
	/// How much damage we've been hit with
	var/damage_sustained = 0
	/// How much damage we can be hit with before it starts rolling reveal chances
	var/damage_before_reveal = 25
	/// The image we place over the owner
	var/image/cloak_image

/datum/status_effect/shadow_cloak/on_apply()
	cloak_image = image('mods/heretic/icons/effects/heretic_effects.dmi', owner, "curse", dir = owner.dir)
	cloak_image.override = TRUE
	cloak_image.alpha = 0
	animate(cloak_image, alpha = 255, 0.2 SECONDS)
	owner.AddOverlays(cloak_image)
	// Add the relevant traits and modifiers
	// owner.add_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS, TRAIT_NO_SNOWPRINTS), TRAIT_STATUS_EFFECT(id))
	// Register signals to cause effects
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(owner, COMSIG_MOB_LAYING_UPDATED, PROC_REF(on_body_position_change))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	return TRUE

/datum/status_effect/shadow_cloak/on_remove()
	// Remove image
	owner.CutOverlays(cloak_image)
	QDEL_NULL(cloak_image)
	// Remove traits and modifiers
	// owner.remove_traits(list(TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE, TRAIT_SILENT_FOOTSTEPS, TRAIT_NO_SNOWPRINTS), TRAIT_STATUS_EFFECT(id))
	// Clear signals
	UnregisterSignal(owner, list(
		COMSIG_ATOM_DIR_CHANGE,
		COMSIG_MOB_LAYING_UPDATED,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOVABLE_MOVED,
	))

/// Signal proc for [COMSIG_ATOM_DIR_CHANGE], handles turning the effect as we turn
/datum/status_effect/shadow_cloak/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	cloak_image.dir = new_dir

/// Signal proc for [COMSIG_MOB_LAYING_UPDATED], handles rotating the effect when we're downed
/datum/status_effect/shadow_cloak/proc/on_body_position_change(datum/source, new_value, old_value)
	SIGNAL_HANDLER

	if(owner.lying)
		cloak_image.transform = turn(cloak_image.transform, 90)
	else
		cloak_image.transform = turn(cloak_image.transform, -90)

/// Signal proc for [SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT], falling unconscious (from hard crit or otherwise) will stop the effect
/datum/status_effect/shadow_cloak/proc/on_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER

	// Going above unconscious will self-delete
	qdel(src)

/// Signal proc for [COMSIG_MOB_APPLY_DAMAGE], being damaged past a threshold will roll a chance to stop the effect
/datum/status_effect/shadow_cloak/proc/on_damaged(datum/source, damage, damagetype, ...)
	SIGNAL_HANDLER

	// Stam damage is generally bursty, so we'll half it
	if(damagetype == DAMAGE_SHOCK)
		damage *= 0.5

	// Add incoming damage to the total damage sustained
	damage_sustained += damage
	// If we're not past the threshold, return
	if(damage_sustained < damage_before_reveal)
		return

	// Otherwise, we have a probability based on how much damage sustained to self delete
	if(prob(damage_sustained))
		qdel(src)

/// Signal proc for [COMSIG_MOVABLE_MOVED], leaves a cool looking trail behind us as we walk
/datum/status_effect/shadow_cloak/proc/on_move(datum/source, old_loc, movement_dir)
	SIGNAL_HANDLER

	if(owner.loc == old_loc)
		return
/*
	// Only create an effect every other step, starting without one
	var/obj/effect/afterimage/shadow_cloak/trail = new (old_loc, movement_dir)
	if(owner.lying)
		trail.transform = turn(trail.transform, 90)


/obj/effect/afterimage/shadow_cloak
	name = "afterimage"
	icon = 'mods/heretic/icons/effects/heretic_effects.dmi'
	icon_state = "curse"
	anchored = TRUE

/datum/effect/trail/afterimage/shadow_cloak
	trail_type = /obj/effect/afterimage/shadow_cloak
	duration_of_effect = 10
	specific_turfs = list(/turf)

/datum/effect/trail/afterimage/shadow_cloak/effect(obj/effect/T)
	..()
	flick("curse", T)
	T.icon_state = "blank"
 */
