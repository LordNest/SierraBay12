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
	/// Currently selected node in the research tree UI
	var/selected_node_id
	/// Route string of the branch currently open in the UI (null on hub)
	var/ui_preview_route
	/// When TRUE, show the path selection hub instead of a branch tree
	var/ui_viewing_hub = TRUE

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
	owner = player
	. = ..()
	initialize_heretic_setup()

	var/datum/action/datumized/antag_info/A = new(src)
	A.Grant(player.current)

/datum/antagonist/heretic/nano_host()
	return owner?.current

/datum/antagonist/heretic/proc/initialize_heretic_setup()
	generate_heretic_starting_knowledge(heretic_shops[HERETIC_KNOWLEDGE_START])
	path_info.Cut()
	for(var/datum/heretic_knowledge_tree_column/path_type as anything in subtypesof_real(/datum/heretic_knowledge_tree_column))
		var/datum/heretic_knowledge_tree_column/path = new path_type()
		if(!path.start)
			qdel(path)
			continue
		path_info += list(path.get_ui_data(src, HERETIC_KNOWLEDGE_START))
		qdel(path)
	for(var/starting_knowledge in GLOB.heretic_start_knowledge)
		gain_knowledge(starting_knowledge, HERETIC_KNOWLEDGE_START, update = FALSE)


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

/datum/antagonist/heretic/proc/get_nano_icon(mob/user, icon_file, icon_state = "")
	if(!user?.client || !icon_file)
		return ""
	var/icon/I = icon(icon_file, icon_state || "")
	var/key = "[generate_asset_name(I)].png"
	register_asset(key, I)
	send_asset(user.client, key)
	return key

/datum/antagonist/heretic/proc/get_icon_of_knowledge(datum/heretic_knowledge/knowledge)
	var/icon_path = 'mods/heretic/icons/actions_ecult.dmi'
	var/icon_state = "eye"
	var/icon_frame = initial(knowledge.research_tree_icon_frame)
	var/icon_dir = initial(knowledge.research_tree_icon_dir)
	var/icon_moving = FALSE

	if(!isnull(initial(knowledge.research_tree_icon_path)))
		icon_path = initial(knowledge.research_tree_icon_path)
		icon_state = initial(knowledge.research_tree_icon_state)

	else if(ispath(knowledge, /datum/heretic_knowledge/spell))
		var/datum/heretic_knowledge/spell/spell_knowledge = knowledge
		var/datum/action/action_type = initial(spell_knowledge.action_to_add)
		if(ispath(action_type, /datum/action))
			icon_path = initial(action_type.button_icon)
			icon_state = initial(action_type.button_icon_state)

	else if(ispath(knowledge, /datum/heretic_knowledge/summon))
		var/datum/heretic_knowledge/summon/summon_knowledge = knowledge
		var/mob/mob_type = initial(summon_knowledge.mob_to_summon)
		if(ispath(mob_type, /mob))
			icon_path = initial(mob_type.icon)
			icon_state = initial(mob_type.icon_state)

	var/list/result_parameters = list()
	result_parameters["icon"] = icon_path
	result_parameters["state"] = icon_state
	result_parameters["frame"] = icon_frame
	result_parameters["dir"] = icon_dir
	result_parameters["moving"] = icon_moving
	return result_parameters

/datum/antagonist/heretic/proc/prepare_knowledge_for_nano(mob/user, datum/heretic_knowledge/knowledge, list/source_list, done = FALSE, category = HERETIC_KNOWLEDGE_TREE)
	var/list/knowledge_data = get_knowledge_data(knowledge, source_list, done, category)
	var/list/icon_params = knowledge_data["icon_params"]
	var/list/safe = list(
		"path" = "[knowledge_data["path"]]",
		"name" = "[knowledge_data["name"]]",
		"desc" = "[knowledge_data["desc"]]",
		"cost" = knowledge_data["cost"],
		"depth" = knowledge_data["depth"],
		"bgr" = knowledge_data["bgr"],
		"category" = knowledge_data[HKT_CATEGORY],
		"ascension" = knowledge_data["ascension"],
		"done" = knowledge_data["done"],
		"icon_params" = list(
			"icon" = "[icon_params["icon"]]",
			"state" = "[icon_params["state"]]",
		),
	)
	if(knowledge_data["gainFlavor"])
		safe["gainFlavor"] = "[knowledge_data["gainFlavor"]]"
	if(ispath(knowledge, /datum/heretic_knowledge/ultimate))
		var/ascension_check = can_ascend()
		if(ascension_check != HERETIC_CAN_ASCEND)
			safe["disabled"] = TRUE
			safe["tooltip"] = "[ascension_check]"
	return safe

/datum/antagonist/heretic/proc/build_path_selection_data(mob/user)
	var/list/paths = list()
	for(var/list/path_entry in path_info)
		if(!islist(path_entry) || !islist(path_entry["starting_knowledge"]))
			continue
		var/list/starting = path_entry["starting_knowledge"]
		var/list/icon_data = path_entry["icon"]
		var/route = path_entry["route"]
		var/list/card = list(
			"route" = route,
			"display_name" = "[GLOB.heretic_path_names[route] || route]",
			"complexity" = "[path_entry["complexity"]]",
			"complexity_color" = "[path_entry["complexity_color"]]",
			"desc_summary" = islist(path_entry["description"]) && length(path_entry["description"]) ? "[path_entry["description"][1]]" : "",
			"pros_summary" = islist(path_entry["pros"]) ? "[jointext(path_entry["pros"], "; ")]" : "",
			"cons_summary" = islist(path_entry["cons"]) ? "[jointext(path_entry["cons"], "; ")]" : "",
			"is_committed" = (heretic_path && heretic_path.route == route) ? 1 : 0,
			"starting_knowledge" = list(
				"path" = "[starting["path"]]",
				"cost" = starting["cost"],
			),
		)
		if(islist(icon_data) && user?.client)
			card["icon_url"] = get_nano_icon(user, icon_data["icon"], icon_data["state"])
		paths += list(card)
	return paths

/datum/antagonist/heretic/proc/format_tree_node(mob/user, datum/heretic_knowledge/knowledge, list/source_list, done = FALSE, category = HERETIC_KNOWLEDGE_TREE, list/researchable = null)
	var/list/node = prepare_knowledge_for_nano(user, knowledge, source_list, done, category)
	var/list/icon_params = get_icon_of_knowledge(knowledge)
	node["icon"] = user?.client ? get_nano_icon(user, icon_params["icon"], icon_params["state"]) : ""
	node["id"] = source_list[knowledge][HKT_ID]
	node -= "icon_params"

	var/disabled = node["disabled"] || FALSE
	var/canunlock = 0
	var/can_buy = 0
	if(!isnull(researchable))
		canunlock = (node["id"] in researchable) && !disabled
		can_buy = canunlock && (source_list[knowledge][HKT_COST] <= knowledge_points)
	node["canunlock"] = canunlock ? 1 : 0
	node["can_buy"] = can_buy ? 1 : 0
	node["isresearched"] = done ? 1 : 0
	return node

	node["isresearched"] = done ? 1 : 0
	return node

/datum/antagonist/heretic/proc/assemble_tree_display(mob/user, list/all_nodes, list/researchable)
	var/list/tree_nodes = list()
	var/list/tree_lines = list()
	var/list/node_positions = list()

	var/list/depth_groups = list()
	for(var/knowledge_path in all_nodes)
		var/list/entry = all_nodes[knowledge_path]
		var/depth = entry["source"][knowledge_path][HKT_DEPTH]
		if(!depth_groups["[depth]"])
			depth_groups["[depth]"] = list()
		depth_groups["[depth]"] += knowledge_path

	for(var/depth_key in depth_groups)
		var/list/group = depth_groups[depth_key]
		var/depth = text2num(depth_key)
		var/count = length(group)
		var/index = 1
		for(var/knowledge_path in group)
			var/x_pos = round((index / (count + 1)) * 100)
			var/y_pos = round((depth / HKT_DEPTH_ASCENSION) * 90)
			node_positions[all_nodes[knowledge_path]["source"][knowledge_path][HKT_ID]] = list("x" = x_pos, "y" = y_pos)
			index++

	for(var/knowledge_path in all_nodes)
		var/list/entry = all_nodes[knowledge_path]
		var/list/source_list = entry["source"]
		var/list/node = format_tree_node(user, knowledge_path, source_list, entry["done"], entry["category"], researchable)
		var/list/pos = node_positions[node["id"]]
		node["x"] = pos ? pos["x"] : 50
		node["y"] = pos ? pos["y"] : 50
		tree_nodes += list(node)

		var/list/next_ids = source_list[knowledge_path][HKT_NEXT]
		for(var/next_id in next_ids)
			if(!node_positions[next_id] || !pos)
				continue
			var/list/next_pos = node_positions[next_id]
			tree_lines += list(list(
				"line_x" = min(pos["x"], next_pos["x"]),
				"line_y" = min(pos["y"], next_pos["y"]),
				"width" = abs(pos["x"] - next_pos["x"]),
				"height" = abs(pos["y"] - next_pos["y"]),
				"istop" = (next_pos["y"] > pos["y"]),
				"isright" = (next_pos["x"] < pos["x"]),
			))

	var/list/selected_node = null
	if(selected_node_id)
		for(var/list/node in tree_nodes)
			if(node["id"] == selected_node_id)
				selected_node = node
				break
	if(!selected_node && length(tree_nodes))
		selected_node = tree_nodes[1]
		selected_node_id = selected_node["id"]

	return list(
		"tree_nodes" = tree_nodes,
		"tree_lines" = tree_lines,
		"selected_node_id" = selected_node_id,
		"selected_node" = selected_node,
	)

/datum/antagonist/heretic/proc/build_branch_preview_tree(mob/user, route)
	if(!length(GLOB.heretic_path_knowledges))
		GLOB.heretic_path_knowledges = generate_global_heretic_tree()

	var/list/path_tree = GLOB.heretic_path_knowledges[route]
	if(!length(path_tree))
		return list("tree_nodes" = list(), "tree_lines" = list(), "selected_node_id" = null, "selected_node" = null)

	var/datum/heretic_knowledge_tree_column/column_path = GLOB.heretic_path_datums[route]
	var/list/start_shop = heretic_shops[HERETIC_KNOWLEDGE_START]
	var/list/all_nodes = list()

	if(column_path?.start && start_shop[column_path.start])
		all_nodes[column_path.start] = list(
			"source" = start_shop,
			"done" = !!researched_knowledge[column_path.start],
			"category" = HERETIC_KNOWLEDGE_START,
		)

	for(var/knowledge_path in path_tree)
		if(all_nodes[knowledge_path])
			continue
		all_nodes[knowledge_path] = list(
			"source" = path_tree,
			"done" = !!researched_knowledge[knowledge_path],
			"category" = HERETIC_KNOWLEDGE_TREE,
		)

	return assemble_tree_display(user, all_nodes, null)

/datum/antagonist/heretic/proc/get_path_starting_knowledge(route)
	for(var/list/path_entry in path_info)
		if(path_entry["route"] == route && islist(path_entry["starting_knowledge"]))
			return path_entry["starting_knowledge"]
	return null

/datum/antagonist/heretic/proc/build_tree_ui_data(mob/user)
	var/list/researchable = get_researchable_knowledge()
	var/list/all_nodes = list()

	for(var/knowledge_path in researched_knowledge)
		var/list/knowledge_info = researched_knowledge[knowledge_path]
		all_nodes[knowledge_path] = list(
			"source" = researched_knowledge,
			"done" = TRUE,
			"category" = knowledge_info[HKT_CATEGORY],
		)

	var/list/shop_categories = list(HERETIC_KNOWLEDGE_TREE, HERETIC_KNOWLEDGE_DRAFT, HERETIC_KNOWLEDGE_SHOP)
	for(var/shop_category in shop_categories)
		var/list/shop = heretic_shops[shop_category]
		for(var/knowledge_path in shop)
			if(all_nodes[knowledge_path])
				continue
			if(ispath(knowledge_path, /datum/heretic_knowledge/limited_amount/starting))
				continue
			var/list/knowledge_info = shop[knowledge_path]
			if(!(knowledge_info[HKT_ID] in researchable))
				continue
			all_nodes[knowledge_path] = list(
				"source" = shop,
				"done" = FALSE,
				"category" = shop_category,
			)

	return assemble_tree_display(user, all_nodes, researchable)

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
	knowledge_data[HKT_CATEGORY] = source_list[knowledge][HKT_CATEGORY] || category
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

/datum/antagonist/heretic/ui_interact(mob/living/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/nanoui/master_ui = null, datum/topic_state/state = GLOB.self_state)
	if(user != owner?.current)
		return

	var/list/data = list()
	data["charges"] = knowledge_points
	data["passive_level"] = passive_level
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["points_to_aura"] = points_to_aura

	var/list/objective_data = list()
	if(owner?.objectives)
		for(var/datum/objective/objective in owner.objectives)
			objective_data += list(list("explanation" = "[objective.explanation_text]"))
	data["objectives"] = objective_data
	data["committed_route"] = heretic_path ? heretic_path.route : ""

	if(ui_viewing_hub || (!heretic_path && !ui_preview_route))
		data["screen"] = "hub"
		data["paths"] = build_path_selection_data(user)
	else
		var/route = ui_preview_route || heretic_path.route
		var/can_research = heretic_path && heretic_path.route == route
		data["screen"] = "branch"
		data["preview_route"] = route
		data["path_name"] = "[GLOB.heretic_path_names[route] || route]"
		data["can_research"] = can_research ? 1 : 0
		data["can_commit"] = heretic_path ? 0 : 1
		if(can_research)
			data += build_tree_ui_data(user)
		else
			data += build_branch_preview_tree(user, route)
		var/list/starting = get_path_starting_knowledge(route)
		if(starting)
			data["starting_knowledge"] = list(
				"path" = "[starting["path"]]",
				"cost" = starting["cost"],
			)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mods-heretic.tmpl", "Necronimicon", 1200, 750, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(0)

/datum/antagonist/heretic/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["back_to_hub"])
		ui_viewing_hub = TRUE
		ui_preview_route = null
		selected_node_id = null
		if(owner?.current)
			ui_interact(owner.current)
		return TRUE

	if(href_list["view_path"])
		ui_viewing_hub = FALSE
		ui_preview_route = href_list["view_path"]
		selected_node_id = null
		if(owner?.current)
			ui_interact(owner.current)
		return TRUE

	if(href_list["commit_path"])
		if(heretic_path)
			return FALSE
		var/route = href_list["route"]
		var/datum/heretic_knowledge_tree_column/column_path = GLOB.heretic_path_datums[route]
		if(!column_path?.start)
			return FALSE
		if(!purchase_knowledge(column_path.start, HERETIC_KNOWLEDGE_START))
			if(owner?.current)
				to_chat(owner.current, SPAN_WARNING("You cannot commit to this path right now."))
			return FALSE
		ui_viewing_hub = FALSE
		ui_preview_route = route
		selected_node_id = null
		log_and_message_admins("[key_name(owner)] committed to heretic path: [GLOB.heretic_path_names[route] || route]")
		if(owner?.current)
			to_chat(owner.current, SPAN_NOTICE("You have embraced the [GLOB.heretic_path_names[route] || route]. The way forward is open."))
			ui_interact(owner.current)
		return TRUE

	if(href_list["select_node"])
		selected_node_id = href_list["select_node"]
		if(owner?.current)
			ui_interact(owner.current)
		return TRUE

	if(href_list["research"])
		if(!heretic_path)
			if(owner?.current)
				to_chat(owner.current, SPAN_WARNING("Choose a path before researching knowledge."))
			return FALSE
		var/knowledge_href = href_list["path"]
		if(istext(knowledge_href))
			knowledge_href = text2path(knowledge_href)
		var/datum/heretic_knowledge/researched_path = knowledge_href
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
			if(owner?.current)
				to_chat(owner.current, SPAN_WARNING("You cannot research that knowledge right now."))
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
	pawn.equip_to_slot_if_possible(new /obj/item/clothing/accessory/amulet/heretic_focus(get_turf(pawn)), SLOT_MASK, TRUE, TRUE)
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
/datum/antagonist/heretic/proc/gain_knowledge(datum/heretic_knowledge/knowledge_type, category = HERETIC_KNOWLEDGE_TREE, update = TRUE)
	var/list/knowledge_list = heretic_shops[category]
	if(!ispath(knowledge_type))
		stack_trace("[type] gain_knowledge was given an invalid path! (Got: [knowledge_type])")
		return FALSE
	var/list/knowledge_data = knowledge_list[knowledge_type]
	if(!islist(knowledge_data))
		knowledge_data = make_knowledge_entry(knowledge_type, null, category)
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
