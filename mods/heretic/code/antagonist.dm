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


/// Same as iscultist() check if we're heretic
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

/datum/antagonist/heretic/add_antagonist(datum/mind/player)
	. = ..()

	var/datum/action/datumized/antag_info/A = new(src)
	A.Grant(player.current)


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

/datum/antagonist/heretic/ui_interact(mob/living/user, ui_key = "main", datum/nanoui/ui = null)
	. = ..()
	var/list/data = list()

	data["charges"] = knowledge_points

	data["objectives"] = user.mind.objectives

	data["paths"] = path_info
	data["passive_level"] = passive_level

	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["points_to_aura"] = points_to_aura

	var/list/tree_data = list()
	var/list/shop_knowledge = list()

	// This should be cached in some way, but the fact that final knowledge
	// has to update its disabled state based on whether all objectives are complete,
	// makes this very difficult. I'll figure it out one day maybe
	for(var/knowledge_path in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_path]
		/// draft knowledges are only shown post-research
		var/list/knowledge_data = get_knowledge_data(knowledge_path, researched_knowledge, TRUE, knowledge_info[HKT_CATEGORY])
		var/category = knowledge_info[HKT_CATEGORY]

		var/depth = knowledge_info[HKT_DEPTH]
		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		if(category == HERETIC_KNOWLEDGE_SHOP || category == HERETIC_KNOWLEDGE_DRAFT)
			shop_knowledge += list(knowledge_data)
			continue

		tree_data[depth]["nodes"] += list(knowledge_data)

	// TODO: sanity for purchasing categories as bypasses are likely rn
	var/list/heretic_tree = heretic_shops[HERETIC_KNOWLEDGE_TREE]
	var/list/researchable_knowledges = get_researchable_knowledge()
	for(var/datum/heretic_knowledge/knowledge_path as anything in heretic_tree)
		if(ispath(knowledge_path, /datum/heretic_knowledge/limited_amount/starting))
			continue
		var/list/knowledge_info = heretic_tree[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge_path, heretic_tree, FALSE)

		// Final knowledge can't be learned until all objectives are complete.
		if(ispath(knowledge_path, /datum/heretic_knowledge/ultimate))
			var/ascension_check = can_ascend()
			if(ascension_check != HERETIC_CAN_ASCEND)
				knowledge_data["disabled"] = TRUE
				knowledge_data["tooltip"] = ascension_check


		var/depth = knowledge_data[HKT_DEPTH]

		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		tree_data[depth]["nodes"] += list(knowledge_data)


	if(!heretic_path)
		data["knowledge_tiers"] = tree_data
		return data

	var/list/heretic_drafts = heretic_shops[HERETIC_KNOWLEDGE_DRAFT]
	for(var/datum/heretic_knowledge/knowledge_path as anything in heretic_drafts)
		var/list/knowledge_info = heretic_drafts[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue
		var/list/knowledge_data = get_knowledge_data(knowledge_path, heretic_drafts, FALSE, HERETIC_KNOWLEDGE_DRAFT)

		var/depth = knowledge_data[HKT_DEPTH]
		while(depth > length(tree_data))
			tree_data += list(list("nodes" = list()))

		tree_data[depth]["nodes"] += list(knowledge_data)

	data["knowledge_tiers"] = tree_data
	var/list/shop = heretic_shops[HERETIC_KNOWLEDGE_SHOP]
	for(var/knowledge_path in shop)
		var/list/knowledge_info = shop[knowledge_path]
		if(!(knowledge_info[HKT_ID] in researchable_knowledges))
			continue

		var/list/knowledge_data = get_knowledge_data(knowledge_path, shop, FALSE, HERETIC_KNOWLEDGE_SHOP)
		shop_knowledge += list(knowledge_data)

	data["knowledge_shop"] = shop_knowledge

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "mods-heretic.tmpl", "Necronimicon", 1200, 700)

		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)

/datum/antagonist/heretic/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["research"])
		var/datum/heretic_knowledge/researched_path = href_list["path"]
		if(!ispath(researched_path, /datum/heretic_knowledge))
			CRASH("Heretic attempted to learn non-heretic_knowledge path! (Got: [researched_path || "invalid path"])")
		var/shop_category = href_list["category"]
		if(!researchable_knowledge(researched_path, shop_category))
			message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn knowledge they can't learn!")
			CRASH("Heretic attempted to learn knowledge they can't learn! (Got: [researched_path])")
		if(ispath(researched_path, /datum/heretic_knowledge/ultimate) & can_ascend() != HERETIC_CAN_ASCEND)
			message_admins("Heretic [key_name(owner)] potentially attempted to href exploit to learn ascension knowledge without completing objectives!")
			CRASH("Heretic attempted to learn a final knowledge despite not being able to ascend!")


		if(!purchase_knowledge(researched_path, shop_category))
			return FALSE
		log_and_message_admins("[key_name(owner)] gained knowledge: [initial(researched_path.name)]")
		return TRUE

/datum/antagonist/heretic/proc/researchable_knowledge(datum/heretic_knowledge/knowledge_path, shop_category = HERETIC_KNOWLEDGE_TREE)
	var/list/knowledge_info = heretic_shops[shop_category][knowledge_path]
	if(knowledge_info[HKT_ID] in get_researchable_knowledge())
		return TRUE
	return FALSE

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
 * Admin proc for easily adding / removing knowledge points.
 */
/datum/antagonist/heretic/proc/admin_change_points(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, SPAN_WARNING("You shouldn't be using this!"))
		return

	var/change_num = input(admin, "Add or remove knowledge points", "Points") as null | num
	if(!change_num || QDELETED(src))
		return

	adjust_knowledge_points(change_num)

/**
 * Admin proc for giving a heretic a focus.
 */
/datum/antagonist/heretic/proc/admin_give_focus(mob/admin)
	if(!admin.client?.holder)
		to_chat(admin, SPAN_WARNING("You shouldn't be using this!"))
		return

	var/mob/living/pawn = owner.current
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/accessory/badge/heretic_focus(get_turf(pawn)), SLOT_MASK, TRUE, TRUE)
	to_chat(pawn, SPAN_OCCULT("The Mansus has manifested you a focus."))

/datum/antagonist/heretic/get_additional_check_antag_output()
	var/list/string_of_knowledge = list()

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		if(istype(knowledge, /datum/heretic_knowledge/ultimate))
			string_of_knowledge += SPAN_BOLD(knowledge.name)
		else
			string_of_knowledge += knowledge.name

	return "<br><b>Research Done:</b><br>[english_list(string_of_knowledge, and_text = ", and ")]<br>"

/*
/datum/antagonist/heretic/antag_panel_objectives()
	. = ..()

	. += "<br>"
	. += "<i><b>Current Targets:</b></i><br>"
	if(LAZYLEN(sac_targets))
		for(var/mob/living/carbon/human/target as anything in sac_targets)
			. += " - <b>[target.real_name]</b>, the [target.mind?.assigned_job?.title || "human"].<br>"

	else
		. += "<i>None!</i><br>"
	. += "<br>"
*/

/datum/antagonist/heretic/proc/purchase_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE, update = TRUE)
	var/list/shop_list = heretic_shops[category]
	if(!shop_list)
		stack_trace("Heretic attempted to learn knowledge from a non-existent category! (Got: [category])")
		return FALSE

	var/list/knowledge_data = shop_list[knowledge_type]
	if(!knowledge_data)
		stack_trace("[type] purchase_knowledge was given a path that doesn't exist in the heretic [category] knowledge list! (Got: [knowledge_type])")
		return FALSE

	var/cost = knowledge_data[HKT_COST]
	if(cost > knowledge_points)
		return FALSE
	if(!gain_knowledge(knowledge_type, category, update))
		return FALSE
	adjust_knowledge_points(-cost, FALSE)
	return TRUE
/**
 * Learns the passed [typepath] of knowledge, creating a knowledge datum
 * and adding it to our researched knowledge list.
 *
 * Returns TRUE if the knowledge was added successfully. FALSE otherwise.
 */
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE) //update = TRUE
	var/list/knowledge_list = heretic_shops[category]
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	var/list/knowledge_data = knowledge_list[knowledge_type]
	if(!islist(knowledge_data))
		knowledge_data = make_knowledge_entry(knowledge_type, category)
		heretic_shops[category][knowledge_type] = knowledge_data
	if(get_knowledge(knowledge_type))
		return FALSE
	var/datum/heretic_knowledge/initialized_knowledge = new knowledge_type()
	if(!initialized_knowledge.pre_research(owner.current, src))
		return FALSE
	researched_knowledge[knowledge_type] = knowledge_data.Copy()
	researched_knowledge[knowledge_type][HKT_INSTANCE] = initialized_knowledge
	researched_knowledge[knowledge_type][HKT_CATEGORY] = category

	// case for letting you modify depth post-purchase
	var/purchased_depth = knowledge_data[HKT_PURCHASED_DEPTH]
	if(purchased_depth != 0 && isnum(purchased_depth))
		researched_knowledge[knowledge_type][HKT_DEPTH] = purchased_depth

	knowledge_list -= knowledge_type

	initialized_knowledge.on_research(owner.current, src)
	// if(update)
	//	update_data_for_all_viewers()

	return TRUE

/**
 * Get a list of all knowledge IDs that we can currently research.
 */
/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_type in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_type]
		researchable_knowledge |= knowledge_info[HKT_NEXT]
		banned_knowledge |= knowledge_info[HKT_BAN]
		banned_knowledge |= knowledge_type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/**
 * Check if the wanted type-path is in the list of research knowledge.
 */
/datum/antagonist/heretic/proc/get_knowledge(wanted)
	var/list/knowledge_data = researched_knowledge[wanted]
	if(knowledge_data)
		return knowledge_data[HKT_INSTANCE]
	return null

/**
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_path in researched_knowledge)
		var/datum/heretic_knowledge/knowledge = researched_knowledge[knowledge_path][HKT_INSTANCE]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals[knowledge.name] = knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_heretic_knowledge), associative = TRUE)

/**
 * Checks to see if our heretic can ccurrently ascend.
 *
 * Returns FALSE if not all of our objectives are complete, or TRUE otherwise.
 */
/datum/antagonist/heretic/proc/can_ascend()
	if(feast_of_owls)
		return "The owls have taken your right of ascension (denied ascension)." // We sold our ambition for immediate power :/
	if(!length(all_sac_targets) >= 5)
		return "Must sacrifice more crewmates before ascension."
	var/config_time = 30 MINUTES

	var/time_passed = world.time
	if(config_time >= time_passed)
		return "Too early, must wait [time2text(config_time - time_passed)] before ascending."
	return HERETIC_CAN_ASCEND

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
