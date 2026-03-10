// Full Metal Alchemist, how are you?

/datum/power/heretic/circle
	name = "Draw Circle"
	desc = "Prepare alchemy circle for ritual perfomance."
	ability_icon_state = "mark"
	knowledgecost = 0
	make_hud_button = 1
	verbpath = /mob/proc/alchemy_rune

/mob/proc/alchemy_rune()
	set category = "Heretic"
	set name = "Draw Circle"
	set desc = "Prepare alchemy circle for ritual perfomance"

	make_circle(/obj/rune/alchemy, cost = 0, codex_required = 0)

/mob/proc/make_circle(rune, cost = 0, codex_required = 0)

	var/has_codex = !!IsHolding(/obj/item/book/codex)
	var/has_robes = 0

	if(!has_codex && codex_required)
		to_chat(src, SPAN_WARNING("This rune is too complex to draw by memory, you need to have a codex in your hand to draw it."))
		return
	if(istype(get_equipped_item(slot_head), /obj/item/clothing/head/culthood) && istype(get_equipped_item(slot_wear_suit), /obj/item/clothing/suit/cultrobes) && istype(get_equipped_item(slot_shoes), /obj/item/clothing/shoes/cult))
		has_robes = 1
	var/turf/T = get_turf(src)
	if(T.holy)
		to_chat(src, SPAN_WARNING("This place is blessed, you may not draw runes on it - defile it first."))
		return
	if(!istype(T, /turf/simulated))
		to_chat(src, SPAN_WARNING("You need more space to draw a rune here."))
		return
	if(locate(/obj/rune) in T)
		to_chat(src, SPAN_WARNING("There's already a rune here.")) // Don't cross the runes
		return
	var/self
	var/timer
	if(has_codex)
		if(has_robes)
			self = "Feeling empowered in your robes, you slice open your finger and start drawing a rune, chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 3 SECONDS
		else
			self = "You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			timer = 4 SECONDS
	else
		self = "Working without your codex, you try to draw the rune from your memory"
		if(has_robes)
			self += ". You don't remember it well, but you feel strangely empowered. You begin chanting, the unknown words slipping into your mind from beyond."
			timer = 5 SECONDS
		else
			self += ", having to cut your finger two more times before you make it resemble the pattern in your memory. It still looks a little off."
			timer = 8 SECONDS
	visible_message(SPAN_WARNING("\The [src] slices open a finger and begins to chant and paint symbols on the floor."), SPAN_NOTICE("[self]"), "You hear chanting.")
	if(do_after(src, timer, T, DO_PUBLIC_UNIQUE))
		if(locate(/obj/rune) in T)
			return
		var/obj/rune/R = new rune(T, get_rune_color(), get_blood_name())
		var/area/A = get_area(R)
		log_and_message_admins("created \an [R.cultname] rune at \the [A.name].")
		R.add_fingerprint(src)
		return 1
	return 0

/// Базовая ритуальная часть

/datum/ritual
	var/name = "Етого никто не должен видеть"
	var/desc = "Master ritual holder, if you see this, inform your local wizard"
	var/icon = null               // Иконка для радиального меню
	var/result = null             // Предмет-результат
	var/list/components = list()  // Компоненты для ритуала
	var/tier = null               // Тир ритуала
	var/path = null               // Путь ритуала (FLESH, HUNT, RIDDLE, COSMOS, SIDE_*)

/// Общие ритуалы
/datum/ritual/sacrifice
	name = "Sacrifice"
	icon = "manequin"
	result = null
	components = list()
	tier = HERETIC_TIER_ONE

/datum/ritual/book
	name = "Codex Cicatrix"
	icon = "necronimicon"
	result = /obj/item/book/codex
	components = list(/obj/item/book)
	tier = HERETIC_TIER_ONE



/obj/rune/alchemy
	name = "rune"
	desc = "A strange collection of symbols drawn in blood."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune3"

	var/datum/ritual/ritual

	var/list/req = list()

	var/mob/living/victim


/obj/rune/alchemy/on_update_icon()
	ClearOverlays()

/obj/rune/alchemy/proc/get_heretics()
	. = list()
	for(var/mob/living/M in range(1, src))
		if(isheretic(M))
			. += M


/obj/rune/alchemy/examine(mob/user, distance)
	. = ..()
	if (distance <= 0)
		to_chat(user, "It currently holds fabrication units.")


/obj/rune/alchemy/attack_hand(mob/living/user)
	convoke()


/obj/rune/alchemy/CtrlClick(mob/living/carbon/human/user)
	var/radial = list()
	for (var/alchemy in user.mind.heretic.known_rituals)
		var/datum/ritual/rite = alchemy
		radial[rite] = mutable_appearance('mods/heretic/icons/heretic_misc.dmi', rite.icon)
	var/choice = show_radial_menu(user, user, radial, require_near = TRUE, radius = 42, tooltips = TRUE, check_locs = list(src))
	if (!choice || !user.use_sanity_check(src))
		return
	ritual = new choice
	to_chat(user, SPAN_NOTICE("Changed ritual to \"[ritual.name]\"."))
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)

/obj/rune/alchemy/proc/convoke(mob/living/user)
	user = usr
	if(istype(ritual, /datum/ritual/sacrifice))
		var/list/mob/living/carbon/human/heretics = get_heretics()
		if(victim)
			to_chat(user, SPAN_WARNING("You are already sarcificing \the [victim] on this rune."))
			return
		if(length(heretics) < 1)
			to_chat(user, SPAN_WARNING("You need three heretics around this rune to make it work."))
			return fizzle(user)
		var/turf/T = get_turf(src)
		for(var/mob/living/M in T)
			if(!M.is_dead() && !isheretic(M))
				victim = M
				break
		if(!victim)
			return fizzle(user)

		for(var/mob/living/M in heretics)
			M.say("Barhah hra zar[pick("'","`")]garis!")

		if(victim && victim.loc == T)
			var/list/mob/living/casters = get_heretics()
			if(length(casters) < 1)
				return
			for(var/mob/M in heretics | get_heretics())
				to_chat(M, SPAN_WARNING("The Geometer of Blood accepts this offering."))
			user.mind.heretic.sacrificed += victim.mind
			if(victim.mind == GLOB.cult.sacrifice_target)
				for(var/datum/mind/H in GLOB.cult.current_antagonists)
					if(H.current)
						to_chat(H.current, SPAN_OCCULT("Your objective is now complete."))
			to_chat(victim, SPAN_OCCULT("The Geometer of Blood claims your body."))
			heretic_sacrifice(victim)
			sleep(40)
		if(victim)
			victim = null
	// Ритуалы помимо жертвоприношения
	if(ritual && !istype(ritual, /datum/ritual/sacrifice))

		var/turf/T = get_turf(src)
		var/list/missing = list()
		for(var/comp_path in ritual.components)
			if(!locate(comp_path) in T)
				// Получаем имя компонента
				var/name = initial(null)
				if(ispath(comp_path))
					var/obj/O = new comp_path
					name = O.name // Тихо пиздим имя компонента и удаляем его. (Можно подход лучше придумать, но я делаю на так пока что)
					qdel(O)
				else
					name = "[comp_path]"
				missing += name
		if(length(missing))
			to_chat(user, SPAN_WARNING("Не хватает компонентов для ритуала: [jointext(missing, ", ")]"))
			return
		else
			to_chat(user, SPAN_COLOR("#ff69b4", "🐴 РИТУАЛ УСПЕШНО СОВЕРШЁН! 🐎"))
	if(!ritual)
		to_chat(user, SPAN_WARNING("Не выбран ритуал"))

/obj/rune/alchemy/proc/heretic_sacrifice()
