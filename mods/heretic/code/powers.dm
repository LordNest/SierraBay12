var/global/list/heretic_powers = typesof(/datum/power/heretic) - /datum/power/heretic	//needed for the badmin verb for now

/datum/mind
	var/datum/heretic/heretic

/datum/heretic

	var/selected_path = null	// Выбранный путь: HERETIC_POWER_FLESH, HUNT, RIDDLE, COSMOS

	var/list/known_rituals = list()
	var/list/sacrificed = list()
	var/list/purchased_powers = list()

	var/knowledgepoints = 3

	var/list/purchased_powers_history = list() //Used for round-end report, includes respec uses too.

// Глобальные списки для heretic
/datum/globals/var/static/list/heretic_powerinstances = list()
/datum/globals/var/static/list/heretic_ritualinstances = list()

/datum/heretic/New(gender=FEMALE)
	..()

/mob/proc/make_heretic()


	if(!mind)				return
	if(!mind.heretic)	mind.heretic = new /datum/heretic(gender)

	// verbs.Add(/datum/heretic/proc/ResearchTree)
	add_language(LANGUAGE_CULT)

	for(var/SK in GLOB.heretic_start_knowledge)
		if(istype(SK, /datum/heretic_knowledge/spell))
			continue
		mind.heretic.known_rituals += SK

	if(!length(GLOB.heretic_powerinstances))
		for(var/P in heretic_powers)
			GLOB.heretic_powerinstances += new P()

	// Инициализация списка ритуалов
	if(!length(GLOB.heretic_ritualinstances))
		for(var/R in typesof(/datum/heretic_knowledge) - GLOB.heretic_start_knowledge)
			var/datum/heretic_knowledge/rit = new R()
			if(rit.tier)	// Только ритуалы с tier (пути и побочные)
				GLOB.heretic_ritualinstances += rit

	// Code to auto-purchase free powers.
	for(var/datum/power/heretic/P in GLOB.heretic_powerinstances)
		if(!P.knowledgecost) // Is it free?
			if(!(P in mind.heretic.purchased_powers)) // Do we not have it already?
				mind.heretic.purchased_powers += P /// Add it.
				mind.heretic.purchasePower(mind, P, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/heretic/P in mind.heretic.purchased_powers)
		if(P.isVerb)
			if(!(P in src.verbs))
				verbs.Add(P.verbpath)
			if(P.make_hud_button)
				if(!src.ability_master)
					src.ability_master = new /obj/screen/movable/ability_master/heretic(null, src)
				src.ability_master.add_heretic_ability(
					object_given = src,
					verb_given = P.verbpath,
					name_given = P.name,
					ability_icon_given = P.ability_icon_state,
					arguments = list()
					)

	var/mob/living/carbon/human/H = src

	var/obj/item/organ/external/parent = H.get_organ(BP_CHEST)
	for(var/obj/item/organ/internal/I in parent.internal_organs)
		if(istype(I,/obj/item/organ/internal/heart))
			parent.internal_organs.Remove(I)

	return TRUE

/obj/screen/movable/ability_master/heretic
	icon = 'mods/heretic/icons/screen_spells.dmi'

//heretic Abilities
/obj/screen/ability/verb_based/heretic
	icon = 'mods/heretic/icons/heretic_powers.dmi'
	icon_state = "heretic_spell_base"
	background_base_state = "heretic"

/obj/screen/ability/verb_based/heretic/on_update_icon()
	ClearOverlays()
	icon_state = "[background_base_state]_spell_base"

	// Добавляем overlay с иконкой способности из нашего файла иконок
	if(ability_icon_state)
		var/mutable_appearance/overlay = mutable_appearance(icon, ability_icon_state)
		AddOverlays(overlay)

/datum/power/heretic
	/// Cost for this power.
	var/knowledgecost = 500000
	/// _defines/gamemode.dm
	var/power_category = null

	var/tier = null

	var/path = null

//use this to force add powers
/obj/screen/movable/ability_master/proc/add_heretic_ability(object_given, verb_given, name_given, ability_icon_given, arguments)
	if(!object_given)
		message_admins("ERROR: add_heretic_ability() was not given an object in its arguments.")
	if(!verb_given)
		message_admins("ERROR: add_heretic_ability() was not given a verb/proc in its arguments.")
	if(get_ability_by_PROC_REF(verb_given))
		return // Duplicate
	var/obj/screen/ability/verb_based/heretic/A = new /obj/screen/ability/verb_based/heretic()
	A.ability_master = src
	A.object_used = object_given
	A.verb_to_call = verb_given
	A.ability_icon_state = ability_icon_given
	A.SetName(name_given)
	if(arguments)
		A.arguments_to_use = arguments
	ability_objects.Add(A)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

/* // Modularheretic, totally stolen from the new player panel.  YAYY
/datum/heretic/proc/ResearchTree()//The new one
	set name = "-Research Tree-"
	set category = "Heretic"
	set desc = "Adapt yourself carefully."

	if(!usr || !usr.mind || !usr.mind.heretic)
		return
	src = usr.mind.heretic

	if(!length(GLOB.heretic_powerinstances))
		for(var/P in powers)
			GLOB.heretic_powerinstances += new P()

	if(!length(GLOB.heretic_ritualinstances))
		for(var/R in typesof(/datum/heretic_knowledge) - /datum/heretic_knowledge/book)
			var/datum/heretic_knowledge/rit = new R()
			if(rit.tier)	// Только ритуалы с tier (пути и побочные)
				GLOB.heretic_ritualinstances += rit

	// Если путь ещё не выбран, показываем экран выбора пути
	if(!selected_path)
		showPathSelection()
		return

	// Основной интерфейс дерева исследований
	showResearchTree()

/datum/heretic/proc/showPathSelection()
	var/dat = "<html><head><title>Выбор Пути Еретика</title></head>"
	dat += "<body>"
	dat += "<table width='600' align='center' cellspacing='0' cellpadding='5'>"
	dat += "<tr><td align='center'>"
	dat += "<font size='5'><b>Выберите свой Путь</b></font><br>"
	dat += "Вы должны выбрать один из четырёх путей силы.<br>"
	dat += "Этот выбор определит доступные вам способности.<br>"
	dat += "<hr>"
	dat += "</td></tr>"

	// Path of Flesh
	dat += "<tr><td align='center' bgcolor='#8B0000'>"
	dat += "<font size='4' color='white'><b>Path of Flesh</b></font><br>"
	dat += "<font size='2' color='white'>Путь плоти, биопанк, исцеление и трансформация тела.</font><br>"
	dat += "<a href='byond://?src=\ref[src];path_select=[HERETIC_POWER_FLESH]'>Выбрать этот путь</a>"
	dat += "</td></tr>"

	// Path of Hunt
	dat += "<tr><td align='center' bgcolor='#2F4F4F'>"
	dat += "<font size='4' color='white'><b>Path of Moonhunter</b></font><br>"
	dat += "<font size='2' color='white'>Путь охотника, вирусы, преследование и возвращение.</font><br>"
	dat += "<a href='byond://?src=\ref[src];path_select=[HERETIC_POWER_HUNT]'>Выбрать этот путь</a>"
	dat += "</td></tr>"

	// Path of Riddle
	dat += "<tr><td align='center' bgcolor='#8B008B'>"
	dat += "<font size='4' color='white'><b>Path of Riddle</b></font><br>"
	dat += "<font size='2' color='white'>Путь загадок, иллюзии, ментальные способности.</font><br>"
	dat += "<a href='byond://?src=\ref[src];path_select=[HERETIC_POWER_RIDDLE]'>Выбрать этот путь</a>"
	dat += "</td></tr>"

	// Path of Cosmos
	dat += "<tr><td align='center' bgcolor='#191970'>"
	dat += "<font size='4' color='white'><b>Path of Cosmos</b></font><br>"
	dat += "<font size='2' color='white'>Путь космоса, древние силы, безумие.</font><br>"
	dat += "<a href='byond://?src=\ref[src];path_select=[HERETIC_POWER_COSMOS]'>Выбрать этот путь</a>"
	dat += "</td></tr>"

	dat += "</table>"
	dat += "</body></html>"

	var/datum/browser/popup = new(usr, "path_selection", "Выбор Пути", 700, 600)
	popup.set_content(dat)
	popup.open()

/datum/heretic/proc/showResearchTree()
	var/dat = "<html><head><title>Heretic Research Tree</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,name,desc,helptext,enhancedtext,power,ownsthis,icon_state,tier,can_afford,src_ref){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>"

					body += "<div style='float:left;margin-right:10px;width:64px;height:64px;background:#333;display:flex;align-items:center;justify-content:center;'><span style='color:#666;font-size:10px;'>" + icon_state + "</span></div>"

					body += "</td><td align='center'>"

					body += "<font size='2'><b>"+desc+"</b></font> <BR>"

					body += "<font size='2'><font color = 'orange'><b>"+helptext+"</b></font></font><BR>"

					if(enhancedtext)
					{
						body += "<font size='2'><font color = 'aquamarine'>Recursive Enhancement Effect: <b>"+enhancedtext+"</b></font></font><BR>"
					}

					body += "<font size='2'><b>Tier: "+tier+"</b></font><BR>"

					if(!ownsthis)
					{
						if(can_afford)
						{
							body += "<a href='byond://?src=" + src_ref + "&P="+power+"' onclick='event.stopPropagation();'><font color='green'>Research</font></a>"
						}
						else
						{
							body += "<font color='red'>Недостаточно очков</font>"
						}
					}
					else
					{
						body += "<font color='green'>Изучено</font>"
					}

					body += "</td><td align='center'>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function expandRitual(id,name,desc,tier,ownsthis,icon_state,cost,can_afford,src_ref){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>"

					body += "<div style='float:left;margin-right:10px;width:64px;height:64px;background:#333;display:flex;align-items:center;justify-content:center;'><span style='color:#666;font-size:10px;'>" + icon_state + "</span></div>"

					body += "</td><td align='center'>"

					body += "<font size='2'><b>"+desc+"</b></font> <BR>"

					body += "<font size='2'><b>Tier: "+tier+"</b></font><BR>"

					body += "<font size='2'><b>Cost: "+cost+" knowledge points</b></font><BR>"

					if(!ownsthis)
					{
						if(can_afford)
						{
							body += "<a href='byond://?src=" + src_ref + "&ritual="+name+"' onclick='event.stopPropagation();'><font color='green'>Learn Ritual</font></a>"
						}
						else
						{
							body += "<font color='red'>Недостаточно очков</font>"
						}
					}
					else
					{
						body += "<font color='green'>Изучен</font>"
					}

					body += "</td><td align='center'>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;

						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){

					clearAll();

					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>heretic Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current evolution points left to Research with: [knowledgepoints]<br>
					Absorb other heretics to acquire more evolution points
					<p>
					<font color='yellow'><b>Ваш путь: [selected_path]</b></font>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1

	// Собираем доступные пути для текущего выбранного пути
	var/list/available_paths = getAvailablePaths(selected_path)

	for(var/datum/power/heretic/P in GLOB.heretic_powerinstances)
		var/ownsthis = 0

		if(P in purchased_powers)
			ownsthis = 1

		// Проверяем, доступна ли эта сила для нашего пути
		if(!canAccessPower(P, available_paths))
			continue

		// Проверяем tier критерии
		var/tier_met = checkTierRequirements(P)
		if(!tier_met)
			continue

		var/color = COLOR_DARKMODE_DARKBACKGROUND
		if(i%2 == 0)
			color = COLOR_DARKMODE_BACKGROUND

		var/can_afford = (knowledgepoints >= P.knowledgecost) ? 1 : 0
		var/icon_state = P.ability_icon_state ? P.ability_icon_state : "heretic_spell_base"
		var/js_icon_state = icon_state

		dat += {"

			<tr id='data[i]' name='[i]'>
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]' href='#' onclick='addToLocked("item[i]","data[i]","notice_span[i]");return false;' style='text-decoration:none;color:inherit;'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P.enhancedtext]","[P]",[ownsthis],"[js_icon_state]",[P.tier],[can_afford],"\ref[src]")'
					>
					<span id='search[i]'><b>Research [P] - Cost: [ownsthis ? "Purchased" : P.knowledgecost]</b></span>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++

	// Добавляем ритуалы в таблицу
	for(var/datum/heretic_knowledge/R in GLOB.heretic_ritualinstances)
		var/ownsthis = 0

		if(R in src.known_rituals)
			ownsthis = 1

		// Проверяем, доступен ли этот ритуал для нашего пути
		if(!canAccessRitual(R, available_paths))
			continue

		// Проверяем tier критерии для ритуалов
		var/tier_met = checkTierRequirementsRitual(R)
		if(!tier_met)
			continue

		var/color = COLOR_DARKMODE_DARKBACKGROUND
		if(i%2 == 0)
			color = COLOR_DARKMODE_BACKGROUND

		var/ritual_cost = getRitualCost(R)
		var/can_afford = (knowledgepoints >= ritual_cost) ? 1 : 0
		var/js_icon_state = R.icon ? R.icon : "rune"

		dat += {"

			<tr id='data[i]' name='[i]'>
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]' href='#' onclick='addToLocked("item[i]","data[i]","notice_span[i]");return false;' style='text-decoration:none;color:inherit;'
					onmouseover='expandRitual("item[i]","[R.name]","[R.desc]","[R.tier]",[ownsthis],"[js_icon_state]",[ritual_cost],[can_afford],"\ref[src]")'
					>
					<span id='search[i]'><b>Ritual [R] - Cost: [ownsthis ? "Изучен" : ritual_cost]</b></span>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	var/datum/browser/popup = new(usr, "powers", "Evolution Tree", 900, 480)
	popup.set_content(dat)
	popup.open()

/datum/heretic/proc/getAvailablePaths(my_path)
	// Возвращает список доступных путей включая основной, побочные и общий
	var/list/paths = list(my_path)

	// Добавляем общий путь
	paths += HERETIC_POWER_GENERAL

	// Определяем побочные пути на основе основного
	if(my_path == HERETIC_POWER_FLESH)
		paths += HERETIC_POWER_SIDE_FH
		paths += HERETIC_POWER_SIDE_FC
	else if(my_path == HERETIC_POWER_HUNT)
		paths += HERETIC_POWER_SIDE_FH
		paths += HERETIC_POWER_SIDE_HR
	else if(my_path == HERETIC_POWER_RIDDLE)
		paths += HERETIC_POWER_SIDE_HR
		paths += HERETIC_POWER_SIDE_RC
	else if(my_path == HERETIC_POWER_COSMOS)
		paths += HERETIC_POWER_SIDE_RC
		paths += HERETIC_POWER_SIDE_FC

	return paths

/datum/heretic/proc/canAccessPower(datum/power/heretic/P, list/available_paths)
	// Проверяем, принадлежит ли сила к одному из доступных путей
	if(P.path in available_paths)
		return TRUE
	return FALSE

/datum/heretic/proc/checkTierRequirements(datum/power/heretic/P)
	// Проверяем, выполнены ли требования к tier для покупки силы
	// Для tier 1 нет требований
	if(P.tier == HERETIC_TIER_ONE)
		return TRUE

	// Для tier 2 нужен хотя бы один купленный power из tier 1 того же пути
	if(P.tier == HERETIC_TIER_TWO)
		for(var/datum/power/heretic/owned in purchased_powers)
			if(owned.path == P.path && owned.tier == HERETIC_TIER_ONE)
				return TRUE
		return FALSE

	// Для tier 3 нужен хотя бы один купленный power из tier 2 того же пути
	if(P.tier == HERETIC_TIER_THREE)
		for(var/datum/power/heretic/owned in purchased_powers)
			if(owned.path == P.path && owned.tier == HERETIC_TIER_TWO)
				return TRUE
		return FALSE

	// Для tier 4 нужен хотя бы один купленный power из tier 3 того же пути
	if(P.tier == HERETIC_TIER_FOUR)
		for(var/datum/power/heretic/owned in purchased_powers)
			if(owned.path == P.path && owned.tier == HERETIC_TIER_THREE)
				return TRUE
		return FALSE

	return FALSE

/datum/heretic/proc/canAccessRitual(datum/heretic_knowledge/R, list/available_paths)
	// Проверяем, принадлежит ли ритуал к одному из доступных путей
	// Если у ритуала есть переменная path, используем её
	if(R.path)
		if(R.path in available_paths)
			return TRUE
		return FALSE

	// Если path не задан, определяем по типу ритуала
	var/ritual_type = lowertext(replacetext(R.type, "/datum/heretic_knowledge/", ""))
	if(findtext(ritual_type, "flesh") && (HERETIC_POWER_FLESH in available_paths))
		return TRUE
	if(findtext(ritual_type, "hunt") && (HERETIC_POWER_HUNT in available_paths))
		return TRUE
	if(findtext(ritual_type, "riddle") && (HERETIC_POWER_RIDDLE in available_paths))
		return TRUE
	if(findtext(ritual_type, "cosmos") && (HERETIC_POWER_COSMOS in available_paths))
		return TRUE

	// Проверяем побочные пути
	if(findtext(ritual_type, "side"))
		if(findtext(ritual_type, "flesh") && findtext(ritual_type, "hunt") && (HERETIC_POWER_SIDE_FH in available_paths))
			return TRUE
		if(findtext(ritual_type, "hunt") && findtext(ritual_type, "riddle") && (HERETIC_POWER_SIDE_HR in available_paths))
			return TRUE
		if(findtext(ritual_type, "riddle") && findtext(ritual_type, "cosmos") && (HERETIC_POWER_SIDE_RC in available_paths))
			return TRUE
		if(findtext(ritual_type, "cosmos") && findtext(ritual_type, "flesh") && (HERETIC_POWER_SIDE_FC in available_paths))
			return TRUE

	return FALSE

/datum/heretic/proc/checkTierRequirementsRitual(datum/heretic_knowledge/R)
	// Проверяем, выполнены ли требования к tier для покупки ритуала
	// Для tier 1 нет требований
	if(R.tier == HERETIC_TIER_ONE)
		return TRUE

	// Определяем путь ритуала
	var/ritual_path = R.path
	if(!ritual_path)
		var/ritual_type = lowertext(replacetext(R.type, "/datum/heretic_knowledge/", ""))
		if(findtext(ritual_type, "flesh"))
			ritual_path = HERETIC_POWER_FLESH
		else if(findtext(ritual_type, "hunt"))
			ritual_path = HERETIC_POWER_HUNT
		else if(findtext(ritual_type, "riddle"))
			ritual_path = HERETIC_POWER_RIDDLE
		else if(findtext(ritual_type, "cosmos"))
			ritual_path = HERETIC_POWER_COSMOS

	// Для tier 2 нужен хотя бы один купленный ритуал из tier 1 того же пути
	if(R.tier == HERETIC_TIER_TWO)
		for(var/datum/heretic_knowledge/owned in known_rituals)
			var/owned_path = owned.path
			if(!owned_path)
				var/owned_type = lowertext(replacetext(owned.type, "/datum/heretic_knowledge/", ""))
				if(findtext(owned_type, "flesh"))
					owned_path = HERETIC_POWER_FLESH
				else if(findtext(owned_type, "hunt"))
					owned_path = HERETIC_POWER_HUNT
				else if(findtext(owned_type, "riddle"))
					owned_path = HERETIC_POWER_RIDDLE
				else if(findtext(owned_type, "cosmos"))
					owned_path = HERETIC_POWER_COSMOS
			if(owned_path == ritual_path && owned.tier == HERETIC_TIER_ONE)
				return TRUE
		return FALSE

	// Для tier 3 нужен хотя бы один купленный ритуал из tier 2 того же пути
	if(R.tier == HERETIC_TIER_THREE)
		for(var/datum/heretic_knowledge/owned in known_rituals)
			var/owned_path = owned.path
			if(!owned_path)
				var/owned_type = lowertext(replacetext(owned.type, "/datum/heretic_knowledge/", ""))
				if(findtext(owned_type, "flesh"))
					owned_path = HERETIC_POWER_FLESH
				else if(findtext(owned_type, "hunt"))
					owned_path = HERETIC_POWER_HUNT
				else if(findtext(owned_type, "riddle"))
					owned_path = HERETIC_POWER_RIDDLE
				else if(findtext(owned_type, "cosmos"))
					owned_path = HERETIC_POWER_COSMOS
			if(owned_path == ritual_path && owned.tier == HERETIC_TIER_TWO)
				return TRUE
		return FALSE

	// Для tier 4 нужен хотя бы один купленный ритуал из tier 3 того же пути
	if(R.tier == HERETIC_TIER_FOUR)
		for(var/datum/heretic_knowledge/owned in known_rituals)
			var/owned_path = owned.path
			if(!owned_path)
				var/owned_type = lowertext(replacetext(owned.type, "/datum/heretic_knowledge/", ""))
				if(findtext(owned_type, "flesh"))
					owned_path = HERETIC_POWER_FLESH
				else if(findtext(owned_type, "hunt"))
					owned_path = HERETIC_POWER_HUNT
				else if(findtext(owned_type, "riddle"))
					owned_path = HERETIC_POWER_RIDDLE
				else if(findtext(owned_type, "cosmos"))
					owned_path = HERETIC_POWER_COSMOS
			if(owned_path == ritual_path && owned.tier == HERETIC_TIER_THREE)
				return TRUE
		return FALSE

	return FALSE

/datum/heretic/proc/getRitualCost(datum/heretic_knowledge/R)
	// Возвращает стоимость ритуала на основе tier
	if(R.tier == HERETIC_TIER_ONE)
		return 5
	if(R.tier == HERETIC_TIER_TWO)
		return 15
	if(R.tier == HERETIC_TIER_THREE)
		return 30
	if(R.tier == HERETIC_TIER_FOUR)
		return 50
	return 10

/datum/heretic/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	if(href_list["path_select"])
		selected_path = href_list["path_select"]
		usr << "Вы выбрали путь: [selected_path]"
		call(/datum/heretic/proc/ResearchTree)()
		return

	if(href_list["P"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		purchasePower(M, href_list["P"])
		call(/datum/heretic/proc/ResearchTree)()
		return

	if(href_list["ritual"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		purchaseRitual(M, href_list["ritual"])
		call(/datum/heretic/proc/ResearchTree)()
		return

 */
/datum/heretic/proc/purchasePower(datum/mind/M, Pname, remake_verbs = 1)
	if(!M || !M.heretic)
		return

	var/datum/power/heretic/Thepower = Pname


	for (var/datum/power/heretic/P in GLOB.heretic_powerinstances)
		if(P.name == Pname)
			Thepower = P
			break


	if(!Thepower)
		to_chat(M.current, "This is awkward. heretic power purchase failed, please report this bug to a coder!")
		return

	if(Thepower in M.heretic.purchased_powers)
		return
/*
	// Проверяем, соответствует ли сила выбранному пути
	var/list/available_paths = getAvailablePaths(M.heretic.selected_path)
	if(!canAccessPower(Thepower, available_paths))
		to_chat(M.current, "Эта сила не принадлежит вашему пути!")
		return

	// Проверяем tier требования
	if(!M.heretic.checkTierRequirements(Thepower))
		to_chat(M.current, "Сначала изучите силы предыдущего уровня!")
		return

	if(M.heretic.knowledgepoints < Thepower.knowledgecost)
		to_chat(M.current, "We cannot Research this... yet.  We must acquire more DNA.")
		return
*/
	M.heretic.knowledgepoints -= Thepower.knowledgecost

	M.heretic.purchased_powers += Thepower

	if(Thepower.knowledgecost > 0)
		M.heretic.purchased_powers_history.Add("[Pname] ([Thepower.knowledgecost] points)")

	if(Thepower.make_hud_button && Thepower.isVerb)
		if(!M.current.ability_master)
			M.current.ability_master = new /obj/screen/movable/ability_master(null, M.current)
		M.current.ability_master.add_heretic_ability(
			object_given = M.current,
			verb_given = Thepower.verbpath,
			name_given = Thepower.name,
			ability_icon_given = Thepower.ability_icon_state,
			arguments = list()
			)

	if(!Thepower.isVerb && Thepower.verbpath)
		call(M.current, Thepower.verbpath)()
	else if(remake_verbs)
		M.current.make_heretic()
/*
/datum/heretic/proc/purchaseRitual(datum/mind/M, ritual_name, remake_verbs = 1)
	if(!M || !M.heretic)
		return

	var/datum/heretic_knowledge/TheRitual

	// Ищем ритуал по имени
	for (var/datum/heretic_knowledge/R in GLOB.heretic_ritualinstances)
		if(R.name == ritual_name)
			TheRitual = R
			break

	if(!TheRitual)
		to_chat(M.current, "Ритуал не найден!")
		return

	if(TheRitual in M.heretic.known_rituals)
		return

	// Проверяем, соответствует ли ритуал выбранному пути
	var/list/available_paths = getAvailablePaths(M.heretic.selected_path)
	if(!canAccessRitual(TheRitual, available_paths))
		to_chat(M.current, "Этот ритуал не принадлежит вашему пути!")
		return

	// Проверяем tier требования
	if(!M.heretic.checkTierRequirementsRitual(TheRitual))
		to_chat(M.current, "Сначала изучите ритуалы предыдущего уровня!")
		return

	var/ritual_cost = getRitualCost(TheRitual)

	if(M.heretic.knowledgepoints < ritual_cost)
		to_chat(M.current, "Недостаточно очков знаний для изучения этого ритуала!")
		return

	M.heretic.knowledgepoints -= ritual_cost

	M.heretic.known_rituals += TheRitual

	if(ritual_cost > 0)
		M.heretic.purchased_powers_history.Add("Ritual: [ritual_name] ([ritual_cost] points)")

	to_chat(M.current, "Вы изучили ритуал: [TheRitual.name]")
*/
