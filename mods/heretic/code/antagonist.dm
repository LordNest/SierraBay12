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

GLOBAL_TYPED_NEW(heretic, /datum/antagonist/heretic)

/// Копипаст культа, проверка на то, кто мы такие
/proc/isheretic(mob/subject)
	var/datum/mind/mind = subject
	if (ismob(mind))
		mind = subject.mind
	return istype(mind) && (mind in GLOB.heretic?.current_antagonists)

/datum/antagonist/heretic
	id = MODE_HERETIC
	role_text = "heretic"
	role_text_plural = "heretics"
	restricted_jobs = list(/datum/job/lawyer, /datum/job/captain, /datum/job/hos, /datum/job/officer, /datum/job/warden, /datum/job/detective)
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/chaplain, /datum/job/psychiatrist, /datum/job/submap)
	feedback_tag = "heretic_objective"
	antag_indicator = "hudheretic"
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
	antaghud_indicator = "hudheretic"
	skill_setter = /datum/antag_skill_setter/station

	var/allow_ascend = 1
	var/powerless = 0
	var/datum/mind/sacrifice_target
	var/list/sacrificed = list()
	var/heretic_rating = 0
	var/list/heretic_rating_bounds = list(HERETIC_LEVEL_1, HERETIC_LEVEL_2, HERETIC_LEVEL_3)
	var/max_heretic_rating = 0
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
			if(player.mind && !(player.mind in GLOB.heretic.current_antagonists))
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
	remove_heretic_magic(player.current)

/datum/antagonist/heretic/proc/update_heretic_magic(list/to_update)
	if(HERETIC_LEVEL_1 in to_update)
		for(var/datum/mind/H in GLOB.heretic.current_antagonists)
			if(H.current)
				to_chat(H.current, SPAN_OCCULT("То, что было теорией стало пугающей практикой. Картина начинает складываться воедино. Ты на шаг ближе к апофеозу"))
				add_heretic_magic(H.current)
	if(HERETIC_LEVEL_2 in to_update)
		for(var/datum/mind/H in GLOB.heretic.current_antagonists)
			if(H.current)
				to_chat(H.current, SPAN_OCCULT("Ещё! Ещё! Трансмутация за трансмутацией ты становишься ближе к сути. Ты на шаг ближе к апофеозу"))
				add_heretic_magic(H.current)
	if(HERETIC_LEVEL_3 in to_update)
		for(var/datum/mind/H in GLOB.heretic.current_antagonists)
			if(H.current)
				to_chat(H.current, SPAN_OCCULT("Последний ритуал. Последние жертвы. Порог апофеоза перед тобой. Пусть эти жертвы не будут напрасными"))
				add_heretic_magic(H.current)

// Предполагается, что абилки будут достаточно самодостаточны, чтобы давать их сразу все. Поэтому мы не "выдаём", а "разблокируем" их для покупки за очки.

/datum/antagonist/heretic/proc/unlock_heretic_magic(mob/M)
	M.verbs += Tier1Alchemy

	if(max_heretic_rating >= HERETIC_LEVEL_1)
		M.verbs += Tier2Alchemy

		if(max_heretic_rating >= HERETIC_LEVEL_2)
			M.verbs += Tier3Alchemy

			if(max_heretic_rating >= HERETIC_LEVEL_3)
				M.verbs += Tier4Alchemy

/datum/antagonist/heretic/proc/remove_heretic_magic(mob/M)
	M.verbs -= Tier1Alchemy
	M.verbs -= Tier2Alchemy
	M.verbs -= Tier3Alchemy
	M.verbs -= Tier4Alchemy

var/global/list/Tier1Alchemy = list(
	/mob/proc/create_circle
	)

var/global/list/Tier2Alchemy = list(
	/mob/proc/
	)

var/global/list/Tier3Alchemy = list(
	/mob/proc/
)

var/global/list/Tier4Alchemy = list(
	/mob/proc/ascend
	)
