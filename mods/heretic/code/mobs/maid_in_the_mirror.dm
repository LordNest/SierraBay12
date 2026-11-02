/// Scout and assassin who can appear and disappear from glass surfaces. Damaged by being examined.
/mob/living/simple_animal/heretic_summon/maid_in_the_mirror
	name = "\improper Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "A floating and flowing wisp of chilled air. Glancing at it causes it to shimmer slightly."
	icon_state = "manequin"
	icon_living = "manequin" // Placeholder sprite... still
	speak_emote = list("whispers")
	pass_flags = PASS_FLAG_TABLE
	status_flags = CANSTUN | CANPUSH
	attack_sound = 'sound/effects/glass_crack4.ogg'
	maxHealth = 80
	health = 80
	density = TRUE
	sight = SEE_MOBS | SEE_OBJS | SEE_TURFS
	/// Whether we take damage when someone looks at us
	var/harmed_by_examine = TRUE
	/// How often being examined by a specific mob can hurt us
	var/recent_examine_damage_cooldown = 10 SECONDS
	/// A list of REFs to people who recently examined us
	var/list/recent_examiner_refs = list()

/mob/living/simple_animal/heretic_summon/maid_in_the_mirror/Initialize(mapload)
	. = ..()
	var/static/list/loot = list(
		/obj/decal/cleanable/ash,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/organ/internal/lungs,
		/obj/item/material/shard,
	)
	add_language(LANGUAGE_CULT)
	add_language(LANGUAGE_CULT_GLOBAL)
	for(var/spell in summons_spells)
		add_spell(new spell, "const_spell_ready")
	update_icon()

/mob/living/simple_animal/heretic_summon/maid_in_the_mirror/death(gibbed)

	visible_message("shatters and vanishes, releasing a gust of cold air.")
	for (var/turf/T in trange(2, get_turf(src)))
		var/datum/gas_mixture/env = T.return_air()
		if (env)
			env.temperature -= 40
	return ..()

// Examining them will harm them, on a cooldown.
/mob/living/simple_animal/heretic_summon/maid_in_the_mirror/examine(mob/user)
	. = ..()
	if(!harmed_by_examine || user == src || user.stat == DEAD || !isliving(user) || isheretic(user))
		return

	var/user_ref = REF(user)
	if(user_ref in recent_examiner_refs)
		return

	// If we have health, we take some damage
	if(health > (maxHealth * 0.02))
		user.visible_message(
				SPAN_WARNING("[src] seems to fade in and out slightly."),
				SPAN_DANGER("[user]'s gaze pierces your every being!"),
		)

		recent_examiner_refs += user_ref
		apply_damage(maxHealth * 0.02) // We take 2% of our health as damage upon being examined
		playsound(src, 'sound/effects/ghost2.ogg', 40, TRUE)
		addtimer(new Callback(src, PROC_REF(clear_recent_examiner), user_ref), recent_examine_damage_cooldown, TIMER_UNIQUE|TIMER_OVERRIDE)
		animate(src, alpha = 120, time = 0.5 SECONDS, easing = ELASTIC_EASING, loop = 2, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)

	// If we're examined on low enough health we die straight up
	else
		user.visible_message(
				SPAN_DANGER("[src] vanishes from existence!"),
				SPAN_DANGER("[user]'s gaze shatters your form, destroying you!"),
		)

		death()

/mob/living/simple_animal/heretic_summon/maid_in_the_mirror/proc/clear_recent_examiner(mob_ref)
	if(!(mob_ref in recent_examiner_refs))
		return

	recent_examiner_refs -= mob_ref
	heal_overall_damage(5)

/mob/living/simple_animal/heretic_summon/maid_in_the_mirror/apply_melee_effects(atom/A)
	. = ..()
	if(!. || !isliving(A))
		return
	var/mob/living/living_target = A
	living_target.adjustBodyTemp(-10)
