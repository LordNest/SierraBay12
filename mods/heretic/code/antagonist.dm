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

GLOBAL_LIST_EMPTY(heretic_powerinstances)

/datum/mind
	var/datum/heretic/heretic

/datum/heretic
	var/path = null

	var/list/known_rituals = list()
	var/list/sacrificed = list()
	var/list/purchased_powers = list(/datum/power/heretic/circle)

/datum/heretic/New(gender=FEMALE)
	..()

/mob/proc/make_heretic()

	if(!mind)				return
	if(!mind.heretic)	mind.heretic = new /datum/heretic(gender)

	mind.heretic.known_rituals += /datum/ritual/book
	mind.heretic.known_rituals += /datum/ritual/sacrifice
	message_admins("Выдаём ритуалы.")
//	mind.heretic.purchased_powers += /datum/power/heretic/circle
	add_language(LANGUAGE_CULT)

	if(!length(GLOB.powerinstances))
		for(var/P in powers)
			GLOB.powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in GLOB.powerinstances)

	for(var/datum/power/heretic/P in mind.heretic.purchased_powers)
		if(P.isVerb)
			if(!(P in src.verbs))
				verbs.Add(P.verbpath)
			if(P.make_hud_button)
				if(!src.ability_master)
					src.ability_master = new /obj/screen/movable/ability_master(null, src)
				src.ability_master.add_heretic_ability(
					object_given = src,
					verb_given = P.verbpath,
					name_given = P.name,
					ability_icon_given = P.ability_icon_state,
					arguments = list()
					)

//heretic Abilities
/obj/screen/ability/verb_based/heretic
	icon = 'mods/heretic/icons/heretic_powers.dmi'
	icon_state = "heretic_spell_base"
	background_base_state = "bg_heretic_border"

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


/// Копипаст культа, проверка на то, кто мы такие
/proc/isheretic(mob/subject)
	var/datum/mind/mind = subject
	if (ismob(mind))
		mind = subject.mind
	return istype(mind) && (player_is_antag(mind))

/datum/antagonist/heretic
	id = MODE_HERETIC
	role_text = "Heretic"
	role_text_plural = "Heretics"
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
