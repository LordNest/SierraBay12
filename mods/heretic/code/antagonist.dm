/*
Сейчас мы попробуем сформировать еретика на рельсах от Бея, не прибегая к безбожному портированию с ТГ.
Конечно, ТГшный вариант еретика цельный и простое копирование заняло бы меньше времени (если бы не код Бея12)
Но поскольку наш концепт будет отличаться от ТГшного, а именно еретик у нас один, то мы получаем перепиленный культ
Однако это не тот огрызок, который остался в репо Инфинити, потому что там это фактически соло-культист
Большинство пояснений будет на русском языке, для упрощения ревью и потому что я хоть и люблю ставить английские комменты
Но в основном там юморок за триста и малые пояснения. Поэтому начнём. Да, будто это курсач, ага.

P.S. Большинство комментариев будет убрано в процессе ревью, потому что делать я их буду везде
*/

// Сколько мы получаем очков за жертвоприношение или исследование аномалии. Работает аналогично культу. Культисты и псионики дают больше очков. TO DO: Делать культистам больно от такого, чтобы не фидили еретика

#define HERESY_PER_RESEARCH 100
#define HERESY_PER_SACRIFICE 200
#define HERESY_PER_CULTIST 300
#define HERESY_PER_PSIONIC 300

#define HERETIC_LEVEL_1 600
#define HERETIC_LEVEL_2 1200
#define HERETIC_LEVEL_3 2400

#define HERETIC_MAX_LEVEL 3000 // When this value is reached, the game stops checking for updates so we don't recheck every time a tile is converted in endgame

GLOBAL_TYPED_NEW(heretics, /datum/antagonist/heretic)


/// Копипаст культа, проверка на то, кто мы такие
/proc/isheretic(mob/subject)
	var/datum/mind/mind = subject
	if (ismob(mind))
		mind = subject.mind
	return istype(mind) && (mind in GLOB.heretics?.current_antagonists)

/datum/antagonist/heretic
	id = MODE_HERETIC
	role_text = ANTAG_HERETIC
	role_text_plural = ANTAG_HERETIC + "s"
	restricted_jobs = list(/datum/job/lawyer, /datum/job/captain, /datum/job/hos, /datum/job/officer, /datum/job/warden, /datum/job/detective)
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/chaplain, /datum/job/psychiatrist, /datum/job/submap)
	feedback_tag = "heretic_objective"
	antag_indicator = "hudhunter" // Заглушка
	welcome_text = "You have a tome in your possession; one that will help you start the heretic. Use it well and remember - there are others."
	victory_text = "The heretic wins! It has succeeded in serving its dark masters!"
	loss_text = "The staff managed to stop the heretic!"
	victory_feedback_tag = "win - heretic win"
	loss_feedback_tag = "loss - staff stopped the heretic"
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	// Еретик одиночный антаг по аналогии с оперативником
	hard_cap = 1
	hard_cap_round = 1
	initial_spawn_req = 4
	initial_spawn_target = 6
	antaghud_indicator = "hudhunter" // Заглушка
	skill_setter = /datum/antag_skill_setter/station

	///Mind that owns this datum
	var/datum/mind/owner

	/// Contains multiple separate heretic shops so you can choose between multiple when buying.
	var/list/heretic_shops = list(
		HERETIC_KNOWLEDGE_START = list(),
		HERETIC_KNOWLEDGE_TREE = list(),
		HERETIC_KNOWLEDGE_SHOP = list(),
		HERETIC_KNOWLEDGE_DRAFT = list()
	)
	/// A blacklist of turfs we cannot scribe on.
	var/static/list/blacklisted_rune_turfs = typecacheof(list(/turf/space, /turf/simulated/open))
	/// A static list of all paths we can take and related info for the UI
	var/static/list/path_info = list()
	/// Assoc list of [typepath] = [knowledge instance]. A list of all knowledge this heretic's reserached.
	var/list/researched_knowledge = list()
	/// Lazy assoc list of [refs to humans] to [image previews of the human]. Humans that we have as sacrifice targets.
	var/list/mob/living/carbon/human/sac_targets
	/// List of all sacrifice target's names, used for end of round report
	var/list/all_sac_targets = list()
	/// List that keeps track of which items have been gifted to the heretic after a cultist was sacrificed. Used to alter drop chances to reduce dupes.
	var/list/unlocked_heretic_items = list(
		//obj/item/melee/sickly_blade/cursed = 0,
		//obj/item/clothing/neck/heretic_focus/crimson_medallion = 0,
		//mob/living/basic/construct/harvester/heretic = 0,
	)
	/// Whether or not the heretic can make unlimited blades, but unable to blade break to teleport
	var/unlimited_blades = FALSE
	/// Whether we are allowed to ascend
	var/feast_of_owls = FALSE
	/// Whether we give this antagonist objectives on gain.
	var/give_objectives = TRUE
	/// Whether we've ascended! (Completed one of the final rituals)
	var/ascended = FALSE
	/// Whether we're drawing a rune or not
	var/drawing_rune = FALSE
	/// The path our heretic has chosen.
	var/datum/heretic_knowledge_tree_column/heretic_path
	/// Reference to the overlay heretics get when they get strong enough
	// var/static/mutable_appearance/eldritch_overlay = mutable_appearance('icons/mob/effects/heretic_aura.dmi', "heretic_aura")
	/// A sum of how many knowledge points this heretic CURRENTLY has. Used to research.
	var/knowledge_points = 1
	/// The time between gaining influence passively. The heretic gain +1 knowledge points every this duration of time.
	var/passive_gain_timer = 40 MINUTES
	/// Tracks how many knowledge points the heretic has aqcuired. Once you get enough points you lose the ability to blade break
	var/knowledge_gained = 0
	/// The organ slot we place our Living Heart in.
	var/living_heart_organ_slot = BP_HEART
	/// A list of TOTAL how many sacrifices completed. (Includes high value sacrifices)
	var/total_sacrifices = 0
	/// A list of TOTAL how many high value sacrifices completed. (Heads of staff)
	var/high_value_sacrifices = 0
	/// Controls what types of turf we can spread rust to
	var/rust_strength = 1
	/// Simpler version of above used to limit amount of loot that can be hoarded
	var/rewards_given = 0
	/// Our heretic passive level. Tracked here in case of body moving shenanigans
	var/passive_level = 1
	/// How many points are needed to gain a visible heretic aura
	var/points_to_aura = 8

	var/allow_ascend = 1
	var/powerless = 0
	var/datum/mind/sacrifice_target
	var/heretic_rating = 0
	var/list/heretic_rating_bounds = list(HERETIC_LEVEL_1, HERETIC_LEVEL_2, HERETIC_LEVEL_3)
	var/max_heretic_rating = 4
	var/servitude_blurb = "Что-то пафосное про то, как ты теперь хочешь служить робастеру на еретике, не забыть придумать."
	var/station_summon_only = TRUE
	var/no_shuttle_summon = TRUE

	faction = "heretic"

/datum/objective/heretic/ascend
	explanation_text = "Вознестись."

// Обазятельная цель для вознесения. Аналогично культистам требуется принести в жертву определённого члена экипажа

/datum/objective/heretic/sacrifice
	explanation_text = "Conduct a ritual sacrifice."

/datum/objective/heretic/sacrifice/find_target()
	var/list/possible_targets = list()
	if(!length(possible_targets))
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind)
				possible_targets += player.mind
	if(length(possible_targets) > 0)
		target = pick(possible_targets)
	if(target) explanation_text = "Sacrifice [target.name], the [target.assigned_role]."

/datum/antagonist/heretic/create_global_objectives()

	if(!..())
		return

	global_objectives = list()
	global_objectives |= new /datum/objective/heretic/ascend

	var/datum/objective/heretic/sacrifice/sacrifice = new()
	sacrifice.find_target()
	sacrifice_target = sacrifice.target
	global_objectives |= sacrifice

/datum/antagonist/heretic/update_antag_mob(datum/mind/player)
	..()
	player.current.make_heretic()
	player.current.verbs += /mob/proc/alchemy_rune

/datum/antagonist/heretic/equip(mob/living/carbon/human/player)

	if(!..())
		return 0

	var/obj/item/book/codex/T = new(get_turf(player))
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	for(var/slot in slots)
		player.equip_to_slot(T, slot)
		if(T.loc == player)
			break
	var/obj/item/storage/S = locate() in player.contents
	if(istype(S))
		T.forceMove(S)

/datum/antagonist/heretic/remove_antagonist(datum/mind/player, show_message, implanted)
	if(!..())
		return 0
	to_chat(player.current, SPAN_DANGER("Все накопленные знания, всё понимание истинной сущности мироздания ускользают от тебя и превращаются в ничто. Это было дело всей твоей жизни. Или просто сон? Ничего не осталось кроме дороги к безумию."))
	player.ClearMemories(type)
	player.current.remove_language(LANGUAGE_CULT)

//removes our heretic verbs
/mob/proc/remove_heretic_powers()
	if(!mind || !mind.heretic)	return
	for(var/datum/power/heretic/P in mind.heretic.purchased_powers)
		if(P.isVerb)
			verbs.Remove(P.verbpath)
			var/obj/screen/ability/verb_based/heretic/C = ability_master.get_ability_by_PROC_REF(P.verbpath)
			if(C)
				ability_master.remove_ability(C)

// =======================================================================================

/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	//basic icon parameters
	var/icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = knowledge.research_tree_icon_frame
	var/icon_dir = knowledge.research_tree_icon_dir
	//can't imagine why you would want this one, so it can't be overridden by the knowledge
	var/icon_moving = FALSE

	//item transmutation knowledge does not generate its own icon due to implementation difficulties, the icons have to be specified in the override vars

	//if the knowledge has a special icon, use that
	if(!isnull(knowledge.research_tree_icon_path))
		icon_path = knowledge.research_tree_icon_path
		icon_state = knowledge.research_tree_icon_state

	//if the knowledge is a spell, use the spell's button
	else if(ispath(knowledge,/datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/result_action = spell_knowledge.action_to_add
		icon_path = result_action.button_icon
		icon_state = result_action.button_icon_state

	//if the knowledge is a summon, use the mob sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/summon))
		var/datum/heretic_knowledge/summon/summon_knowledge = knowledge
		var/mob/living/result_mob = summon_knowledge.mob_to_summon
		icon_path = result_mob.icon
		icon_state = result_mob.icon_state

	/*
	//if the knowledge is an ascension, use the achievement sprite
	else if(ispath(knowledge,/datum/heretic_knowledge/ultimate))
		var/datum/heretic_knowledge/ultimate/ascension_knowledge = knowledge
			icon_path = ascension_knowledge.research_tree_icon_path
			icon_state = ascension_knowledge.research_tree_icon_state
	*/

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/get_knowledge_data(datum/heretic_knowledge/knowledge, list/source_list, done = FALSE, category = HERETIC_KNOWLEDGE_TREE)
	if(!length(source_list))
		CRASH("get_knowledge_data called without source_list! (Got: [source_list || "empty list"])")
	var/list/knowledge_data = list()

	knowledge_data["path"] = knowledge
	knowledge_data["icon_params"] = get_icon_of_knowledge(knowledge)
	knowledge_data["name"] = initial(knowledge.name)
	knowledge_data["gainFlavor"] = initial(knowledge.gain_text)
	knowledge_data["cost"] = source_list[knowledge][HKT_COST]
	knowledge_data["depth"] = source_list[knowledge][HKT_DEPTH]
	knowledge_data["bgr"] = source_list[knowledge][HKT_UI_BGR]
	knowledge_data[HKT_CATEGORY] = category
	knowledge_data["ascension"] = ispath(knowledge, /datum/heretic_knowledge/ultimate)

	knowledge_data["done"] = done
	//description of a knowledge might change, make sure we are not shown the initial() value in that case
	var/list/knowledge_info = researched_knowledge[knowledge]
	if(islist(knowledge_info))
		var/datum/heretic_knowledge/knowledge_instance = knowledge_info[HKT_INSTANCE]

		knowledge_data["desc"] = knowledge_instance.desc
	else
		knowledge_data["desc"] = initial(knowledge.desc)
	return knowledge_data

/**
 * Create our objectives for our heretic.
 */
/datum/antagonist/heretic/proc/forge_primary_objectives()
	for(var/datum/objective/pick_path/filler in global_objectives)
		filler.owner = null
		global_objectives -= filler
		qdel(filler)

	var/datum/objective/heretic_research/research_objective = new(heretic_research_tree = heretic_shops)
	research_objective.owner = owner
	global_objectives += research_objective

	var/num_heads = 0
	for(var/mob/player in GLOB.player_list)
		if(player.mind.assigned_job.head_position)
			num_heads++

	var/datum/objective/minor_sacrifice/sac_objective = new()
	sac_objective.owner = owner
	if(num_heads < 2) // They won't get major sacrifice, so bump up minor sacrifice a bit
		sac_objective.target_amount = 5
		sac_objective.get_display_text()
	global_objectives += sac_objective

	if(num_heads >= 2)
		var/datum/objective/major_sacrifice/other_sac_objective = new()
		other_sac_objective.owner = owner
		global_objectives += other_sac_objective

/**
 * Add [target] as a sacrifice target for the heretic.
 * Generates a preview image and associates it with a weakref of the mob.
 */
/datum/antagonist/heretic/proc/add_sacrifice_target(mob/living/carbon/human/target)

	var/image/target_image = image(icon = target.icon, icon_state = target.icon_state)
	target_image.overlays = target.overlays

	LAZYSET(sac_targets, target, target_image)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))
	all_sac_targets += target.real_name

/**
 * Removes [target] from the heretic's sacrifice list.
 * Returns FALSE if no one was removed, TRUE otherwise
 */
/datum/antagonist/heretic/proc/remove_sacrifice_target(mob/living/carbon/human/target)
	if(!(target in sac_targets))
		return FALSE

	LAZYREMOVE(sac_targets, target)
	UnregisterSignal(target, COMSIG_QDELETING)
	return TRUE

/**
 * Signal proc for [COMSIG_QDELETING] registered on sac targets
 * if sacrifice targets are deleted (gibbed, dusted, whatever), free their slot and reference
 */
/datum/antagonist/heretic/proc/on_target_deleted(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	remove_sacrifice_target(source)

/**
 * Increments knowledge by one.
 * Used in callbacks for passive gain over time.
 */
/datum/antagonist/heretic/proc/passive_influence_gain()
	adjust_knowledge_points(1)
	// if(owner?.current?.stat <= SOFT_CRIT)
		// to_chat(owner.current, "[span_hear("You hear a whisper...")] [span_hypnophrase(pick_list(HERETIC_INFLUENCE_FILE, "drain_message"))]")
	addtimer(new Callback(src, PROC_REF(passive_influence_gain)), passive_gain_timer)

/datum/antagonist/heretic/proc/adjust_knowledge_points(amount, update = TRUE)
	knowledge_points = max(0, knowledge_points + amount) // Don't allow negative knowledge points
	knowledge_gained += max(0, amount)
	// if(knowledge_gained > points_to_aura && !unlimited_blades)
	//	disable_blade_breaking()
	// if(update)
	// REDO	update_data_for_all_viewers()





/**
 * Helper to determine if a Heretic
 * - Has a Living Heart
 * - Has a an organ in the correct slot that isn't a living heart
 * - Is missing the organ they need in the slot to make a living heart
 *
 * Returns HERETIC_NO_HEART_ORGAN if they have no heart (organ) at all,
 * Returns HERETIC_NO_LIVING_HEART if they have a heart (organ) but it's not a living one,
 * and returns HERETIC_HAS_LIVING_HEART if they have a living heart
 */
/datum/antagonist/heretic/proc/has_living_heart()
	var/mob/living/carbon/human/H = owner.current
	var/obj/item/organ/internal/our_living_heart = H.get_organ(BP_HEART)
	if(!our_living_heart)
		return HERETIC_NO_HEART_ORGAN

//	if(!HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
//		return HERETIC_NO_LIVING_HEART

	return HERETIC_HAS_LIVING_HEART

/datum/objective/pick_path
	explanation_text = "Pick a path to pursue."

/// Heretic's minor sacrifice objective. "Minor sacrifices" includes anyone.
/datum/objective/minor_sacrifice
	explanation_text = "Sacrifice at least four crewmembers."

/// Heretic's major sacrifice objective. "Major sacrifices" are heads of staff.
/datum/objective/major_sacrifice
	target_amount = 1
	explanation_text = "Sacrifice 1 head of staff."

/// Heretic's research objective. "Research" is heretic knowledge nodes (You start with some).
/datum/objective/heretic_research
	target_amount = 1 // You spawn with 1 point

/datum/objective/heretic_research/New(text, list/heretic_research_tree = list())
	. = ..()

	// Factor in the length of the main path
	target_amount += length(heretic_research_tree[HERETIC_KNOWLEDGE_TREE]) || 10
	// Factor in base research we spawn with (otherwise it'd be too easy)
	target_amount += length(GLOB.heretic_start_knowledge)
	// Factor in free knowledge, no challenge there
	target_amount += ceil(length(heretic_research_tree[HERETIC_KNOWLEDGE_DRAFT]) / 3) || 4

	// The actual challenge factor is introduced here, adding a random amount of additional knowledge needed
	target_amount += rand(2, 4)

	get_display_text()

/datum/objective/heretic_research/get_display_text()
	. = ..()
	explanation_text = "Research at least [target_amount] knowledge from the Mansus. You start with [length(GLOB.heretic_start_knowledge)] researched."
