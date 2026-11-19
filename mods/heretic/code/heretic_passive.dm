#define HERETIC_LEVEL_START 1
#define HERETIC_LEVEL_UPGRADE 2
#define HERETIC_LEVEL_FINAL 3

/datum/status_effect/heretic_passive
	id = "heretic_passive"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_REPLACE
	on_remove_on_mob_delete = TRUE
	/// Reference to the owning heretic datum
	var/datum/antagonist/heretic/heretic_datum
	///What level is our passive currently on
	var/passive_level = HERETIC_LEVEL_START
	/// Name of the passive, used by the UI
	var/name = "Heretic Passive"
	/// Describes the various levels of the passive
	var/list/passive_descriptions = list(
		"Grants you a passive ability based on your heretic type. This ability will upgrade as you gain more power.",
		"Your passive ability has been upgraded, doing something else.",
		"Your passive ability has been upgraded to its final form, granting you a powerful new ability.",
	)

/datum/status_effect/heretic_passive/on_apply()
	. = ..()
	heretic_datum = isheretic(owner)
	RegisterSignal(heretic_datum, COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST, PROC_REF(heretic_level_upgrade))
	RegisterSignal(heretic_datum, COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL, PROC_REF(heretic_level_final))
	if(!heretic_datum)
		return FALSE

	// Just in case of shenanigans, assume the antag datum is correct about our level
	if(heretic_datum.passive_level == 3)
		heretic_level_final()
		return
	if(heretic_datum.passive_level == 2)
		heretic_level_upgrade()
		return

/datum/status_effect/heretic_passive/on_remove()
	UnregisterSignal(heretic_datum, list(
		COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST,
		COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL,
	))
	heretic_datum = null
	return ..()

/// Gives our first upgrade
/datum/status_effect/heretic_passive/proc/heretic_level_upgrade()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	passive_level = HERETIC_LEVEL_UPGRADE
	heretic_datum.passive_level = HERETIC_LEVEL_UPGRADE

/// Gives our final upgrade
/datum/status_effect/heretic_passive/proc/heretic_level_final()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	if(passive_level == HERETIC_LEVEL_START)
		heretic_level_upgrade()
	passive_level = HERETIC_LEVEL_FINAL
	heretic_datum.passive_level = HERETIC_LEVEL_FINAL

// recharge_spells был удалён, не вижу смылса в перезарядке спеллов, они у нас не такие долгие + расходуйте время нормально

//---- Blade Passive
// Gives you riposte while wielding a heretic blade
// Cooldown starts at 20 and goes down 5 seconds per level
// Level 1 has a 20 second cooldown + counts as block
// Level 2 Makes you immune to fall damage/stun from falling
// Level 3 only has the cooldown reduction (nothing else added)
/* /datum/status_effect/heretic_passive/blade
	name = "Dance of the Brand"
	id = "blade_passive"
	passive_descriptions = list(
		"Being attacked while wielding a Heretic Blade in either hand will deliver a free, instant counterattack to the attacker. This effect can only trigger once every 20 seconds.",
		"Immunity to fall damage.",
		"Cooldown of the riposte reduced to 10 seconds."
	)
	/// The cooldown before we can riposte again
	var/base_cooldown = 20 SECONDS
	/// The cooldown reduction gained from upgrading
	var/cooldown_reduction = 5 SECONDS
	/// Whether the counter-attack is ready or not.
	/// Used so we can give feedback when it's ready again
	var/riposte_ready = TRUE
	/// Lazylist of refs()s to mobs we've attacked in the last 30 seconds
	VAR_PRIVATE/list/recently_attacked_refs
	/// Lazylist of refs()s to mobs that have attacked us in the last 2 minutes before we attacked them
	VAR_PRIVATE/list/recently_attacked_us_refs

/datum/status_effect/heretic_passive/blade/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_shield_reaction))
	RegisterSignal(owner, COMSIG_USER_PRE_ITEM_ATTACK, PROC_REF(hit_someone))

/datum/status_effect/heretic_passive/blade/proc/hit_someone(mob/living/source, mob/living/target, obj/item/used_weapon)
	SIGNAL_HANDLER

	if(!isliving(target) || target == source)
		return

	// place the attacked mob in the "recently attacked" list so we can mark honorable foes
	var/target_key = REF(target)
	LAZYOR(recently_attacked_refs, target_key)
	addtimer(CALLBACK(src, PROC_REF(remove_attacked_ref), target_key), 30 SECONDS, TIMER_DELETE_ME|TIMER_UNIQUE|TIMER_OVERRIDE)

	if(target.stat == STABLE && LAZYFIND(recently_attacked_us_refs, target_key))
		addtimer(CALLBACK(src, PROC_REF(check_crit), target), 0.2 SECONDS, TIMER_DELETE_ME|TIMER_UNIQUE)

/datum/status_effect/heretic_passive/blade/heretic_level_upgrade()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_Z_IMPACT, PROC_REF(z_impact_react))

/datum/status_effect/heretic_passive/blade/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_LIVING_Z_IMPACT, COMSIG_USER_PRE_ITEM_ATTACK))

/datum/status_effect/heretic_passive/blade/proc/remove_attacked_ref(attacked_key)
	LAZYREMOVE(recently_attacked_refs, attacked_key)

/datum/status_effect/heretic_passive/blade/proc/remove_attacker_ref(attacker_key)
	LAZYREMOVE(recently_attacked_us_refs, attacker_key)

/// Blocks the effects from falling
/datum/status_effect/heretic_passive/blade/proc/z_impact_react(datum/source, levels, turf/fell_on)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/mook_dust(fell_on)
	owner.visible_message(span_notice("[owner] lands on [fell_on] safely, and quite stylishly on [p_their()] feet!"))
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom, SpinAnimation), 0.5 SECONDS, 0)
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/, emote), "flip")
	return ZIMPACT_CANCEL_DAMAGE | ZIMPACT_NO_MESSAGE | ZIMPACT_NO_SPIN

/// Checks if we can counter-attack
/datum/status_effect/heretic_passive/blade/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,
)
	SIGNAL_HANDLER

	var/mob/living/attacker = hitby.loc
	if(!istype(attacker))
		return

	// place the attacker in the list of "recently attacked us" if we did not attack them first
	var/attacker_key = REF(attacker)
	if(!LAZYFIND(recently_attacked_refs, attacker_key))
		LAZYADD(recently_attacked_us_refs, attacker_key)
		addtimer(CALLBACK(src, PROC_REF(remove_attacker_ref), attacker_key), 2 MINUTES, TIMER_DELETE_ME|TIMER_UNIQUE|TIMER_OVERRIDE)

	if(attack_type != MELEE_ATTACK)
		return

	if(!riposte_ready)
		return

	if(INCAPACITATED_IGNORING(source, INCAPABLE_GRAB))
		return

	if(!source.Adjacent(attacker))
		return

	// Let's check their held items to see if we can do a riposte
	var/obj/item/main_hand = source.get_active_held_item()
	var/obj/item/off_hand = source.get_inactive_held_item()
	// This is the item that ends up doing the "blocking" (flavor)
	var/obj/item/striking_with

	// First we'll check if the offhand is valid
	if(!QDELETED(off_hand) && istype(off_hand, /obj/item/melee/sickly_blade))
		striking_with = off_hand

	// Then we'll check the mainhand
	// We do mainhand second, because we want to prioritize it over the offhand
	if(!QDELETED(main_hand) && istype(main_hand, /obj/item/melee/sickly_blade))
		striking_with = main_hand

	// No valid item in either slot? No riposte
	if(!striking_with)
		return

	// If we made it here, deliver the strike
	INVOKE_ASYNC(src, PROC_REF(counter_attack), source, attacker, striking_with, attack_text)

	// And reset after a bit
	riposte_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_riposte), source), (base_cooldown - cooldown_reduction * (passive_level - 1)))

	if(passive_level > HERETIC_LEVEL_START)
		return SUCCESSFUL_BLOCK

/// Does the actual counter-attack
/datum/status_effect/heretic_passive/blade/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	playsound(get_turf(source), 'sound/items/weapons/parry.ogg', 100, TRUE)
	source.balloon_alert(source, "riposte used")
	source.visible_message(
		span_warning("[source] leans into [attack_text] and delivers a sudden riposte back at [target]!"),
		span_warning("You lean into [attack_text] and deliver a sudden riposte back at [target]!"),
		span_hear("You hear a clink, followed by a stab."),
	)
	weapon.melee_attack_chain(source, target)

/// Gives feedback to the user
/datum/status_effect/heretic_passive/blade/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	source.balloon_alert(source, "riposte ready") */

//---- Flesh Passive
// Makes you never get disgust, virus immune and immune to damage from space ants
// Level 2, organs and raw meat heals you. You also become a voracious glutton who likes all food. No slowdown from being fat
// Level 3, being fat gives damage resistance
/datum/status_effect/heretic_passive/flesh
	name = "Ravenous Hunger"
	id = "flesh_passive"
	passive_descriptions = list(
		"Immunity to Diseases, and more resistance to poisons",
		"You can eat most food .",
		"Gain a flat 25% damage and stamina damage reduction when fat as well as baton resistance."
	)

/datum/status_effect/heretic_passive/flesh/on_apply()
	. = ..()
	owner.traits.Add(/singleton/trait/boon/filtered_blood = TRAIT_LEVEL_EXISTS)


/datum/status_effect/heretic_passive/flesh/heretic_level_upgrade()
	. = ..()
	// owner.gluttonous?
	owner.traits.Add(/singleton/trait/boon/cast_iron_stomach = TRAIT_LEVEL_EXISTS)
	if(!ishuman(owner))
		return

/datum/status_effect/heretic_passive/flesh/heretic_level_final()
	. = ..()
	if(!ishuman(owner))
		return

/datum/status_effect/heretic_passive/flesh/on_remove()
	. = ..()
	owner.traits.Remove(/singleton/trait/boon/filtered_blood)
	owner.traits.Remove(/singleton/trait/boon/cast_iron_stomach)
	if(!ishuman(owner))
		return

//---- Lock Passive
// On gain you can understand and speak every language
// Level 1 Shock immunity + Side knowledge is cheaper
// Level 2 Gains X-ray Vision
// Level 3 your grasp no longer goes on cooldown when opening things
/datum/status_effect/heretic_passive/hunt
	name = "Open Invitation"
	id = "lock_passive"
	passive_descriptions = list(
		"Shock insulation, all knowledges researched from the shop are cheaper",
		"X-ray vision, you can see through walls and objects.",
		"Grasp no longer goes on cooldown when used to open a door or locker."
	)
	/// Tracks points needed to be spent to recharge
	var/points_to_recharge = 2

/datum/status_effect/heretic_passive/hunt/on_apply()
	. = ..()
	owner.mutations.Add(mShock)

/datum/status_effect/heretic_passive/hunt/heretic_level_upgrade()
	. = ..()
	owner.mutations.Add(MUTATION_XRAY)
	owner.update_sight()

/datum/status_effect/heretic_passive/hunt/heretic_level_final()
	. = ..()

/datum/status_effect/heretic_passive/hunt/on_remove()
	owner.mutations.Remove(list(mShock, MUTATION_XRAY))
	owner.update_sight()
	return ..()

/datum/status_effect/heretic_passive/hunt/proc/on_shop_setup(datum/antagonist/heretic/heretic_datum)
	SIGNAL_HANDLER
	var/list/shop = heretic_datum.heretic_shops[HERETIC_KNOWLEDGE_SHOP]
	for(var/knowledge_type in shop)
		var/list/heretic_info = shop[knowledge_type]
		if(heretic_info)
			heretic_info[HKT_COST] = max(1, heretic_info[HKT_COST] - 1) // Reduce cost by 1, minimum of 1

//---- Moon Passive
// Heals 5 brain damage per level
// Prevents brain trauma
// Level 2 grants sleep immunity
// Level 3, Mind gate + Ringleader's rise will channel the moon amulet effects
/datum/status_effect/heretic_passive/riddle
	name = "Do You Hear The Voices Too?"
	id = "moon_passive"
	passive_descriptions = list(
		"Passively regenerates brain health.",
		"Clear mind, more resistance to drugs.",
		"Mind gate and Ringleader's rise will channel the moon amulet effects, further inreases brain regeneration."
	)

/datum/status_effect/heretic_passive/riddle/on_apply()
	. = ..()
	var/obj/item/organ/internal/brain/our_brain = owner.get_organ(BP_BRAIN)
	if(!our_brain)
		return

/datum/status_effect/heretic_passive/riddle/tick(seconds_between_ticks)
	. = ..()
	var/healing_amount = (-0.8 * passive_level * seconds_between_ticks)
	if(heretic_datum.ascended)
		healing_amount = -15 * seconds_between_ticks
	owner.adjustBrainLoss(healing_amount)

	var/obj/item/organ/internal/brain/our_brain = owner.get_organ(BP_BRAIN)
	if(!our_brain)
		return

/datum/status_effect/heretic_passive/riddle/heretic_level_upgrade()
	. = ..()
	owner.traits.Add(/singleton/trait/boon/clear_mind = TRAIT_LEVEL_MAJOR)

/datum/status_effect/heretic_passive/riddle/heretic_level_final()
	. = ..()

/datum/status_effect/heretic_passive/riddle/on_remove()
	var/obj/item/organ/internal/brain/our_brain = owner.get_organ(BP_BRAIN)
	if(!our_brain)
		return ..()
	owner.traits.Remove(/singleton/trait/boon/clear_mind)
	return ..()

//---- Void Passive
// Level 1 Cold and Low pressure resist
// Level 2 No breathe
// Level 3 No slip on water/ice
/datum/status_effect/heretic_passive/void
	name = "Aristocrat's Way"
	id = "void_passive"
	passive_descriptions = list(
		"Cold immunity.",
		"You no longer need to breathe.",
		"Low pressure immunity."
	)

	var/list/gained_charges_from

/datum/status_effect/heretic_passive/void/on_apply()
	. = ..()
	owner.mutations.Add(MUTATION_COLD_RESISTANCE)

/datum/status_effect/heretic_passive/void/heretic_level_upgrade()
	. = ..()
	owner.mutations.Add(mNobreath)

/datum/status_effect/heretic_passive/void/heretic_level_final()
	. = ..()
	owner.mutations.Add(MUTATION_SPACERES)

/datum/status_effect/heretic_passive/void/on_remove()
	. = ..()
	owner.mutations.Remove(list(mNobreath, MUTATION_COLD_RESISTANCE, MUTATION_SPACERES))

#undef HERETIC_LEVEL_START
#undef HERETIC_LEVEL_UPGRADE
#undef HERETIC_LEVEL_FINAL
