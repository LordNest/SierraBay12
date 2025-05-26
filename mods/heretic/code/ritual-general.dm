/*
Много копипаста тома культистов + функционал для выбора пути. В базе своей мы просто копипастим. Наше преимущество? Стиль, сука, стиль.
Книжка умеет делать разные приколы, пока реализуем флеш на дизарме раз в минуту.
Ну и нож, куда без него.
*/

/obj/item/book/codex
	name = "codex cicatrix"
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "tome"
	throw_speed = 1
	throw_range = 5
	w_class = 2
	unique = 1
	carved = 2 // Аналогично тому культистов мы это не режем
	var/recharging = 0
	var/last_used = 0 //last world.time it was used.

/obj/item/book/codex/attack_self(mob/living/user)
	if(recharging)
		if(!isheretic(user))
			to_chat(user, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
		else
			to_chat(user, "Сила сокрытая в \ [src] недавно была использована и востановится в течение минуты. Имей терпение.")
	if(!iscultist(user) | !isheretic(user))
		to_chat(user, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
	else
		to_chat(user, "Держи \ [src] в руке, во время жертвоприношений и создания алхимического круга. Обезоружь жертву, целясь книгой в глаза, чтобы открыть ярко сияющую страницу и ослепить её.")

	codex_recharge()

/obj/item/book/codex/examine(mob/user)
	. = ..()
	if(!iscultist(user) | !isheretic(user))
		to_chat(user, "An old, dusty tome with frayed edges and a sinister looking cover.")
	else
		to_chat(user, "Некрономикон мой некрономикон.")

	codex_recharge()

// Люблю спагетти.

/obj/item/book/codex/use_before(mob/living/M, mob/living/user)
	. = FALSE
	if (!istype(M))
		return FALSE
	if (user.a_intent == I_HELP && user.zone_sel.selecting == BP_EYES)
		user.visible_message(
			SPAN_NOTICE("\The [user] shows \the [src] to \the [M]."),
			SPAN_NOTICE("You open up \the [src] and show it to \the [M].")
		)
		if (iscultist(M))
			if (user != M)
				to_chat(user, SPAN_NOTICE("But they already know all there is to know."))
			to_chat(M, SPAN_NOTICE("But you already know all there is to know."))
		else
			to_chat(M, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	if (user.a_intent == I_DISARM && user.zone_sel.selecting == BP_EYES)
		if(!isheretic(user))
			user.visible_message(
				SPAN_NOTICE("\The [user] shows \the [src] to \the [M]."),
				SPAN_NOTICE("You open up \the [src] and show it to \the [M].")
			)
			return
		if(recharging)
			user.visible_message(
				SPAN_NOTICE("\The [user] shows \the [src] to \the [M]."),
				SPAN_NOTICE("You open up \the [src] intended to blind [M] but powers of the book still asleep and you casually show it to \the [M].")
			)
		var/obj/item/nullrod/N = locate() in M
		if(N)
			continue
		if(iscarbon(M))
			M.flash_eyes()
			M.eye_blurry += 50
			M.Weaken(3)
			M.Stun(5)
		else if(issilicon(M))
			M.Weaken(10)
		user.visible_message(
			SPAN_NOTICE("\The [user] shows \the [src], emitting blinding light to \the [M]."),
			SPAN_NOTICE("You open up \the [src], it's pages bright with searing light, and show it to \the [M]."))
		last_used = world.time
		recharging(1)
		if (iscultist(M))
			if (user != M)
				to_chat(user, SPAN_NOTICE("But they already know all there is to know."))
			to_chat(M, SPAN_NOTICE("But you already know all there is to know."))
		else
			to_chat(M, SPAN_NOTICE("\The [src] seems full of illegible scribbles. Is this a joke?"))
		codex_recharge()
		return TRUE

// Хотим как флешка раз в минуту поднимать чардж

/obj/item/book/codex/proc/codex_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 1
	last_used = world.time
	recharging = max(0,round(recharging)) //sanity

/*
Вострый нож
Carving Knife, как с ТГ но не как с ТГ.
Всё у чего есть путь /obj/item/material/knife может им быть, нужно только захотеть, но пока отрисуем основной нож
Основное использование - быть фокусом для жертвоприношения. То есть именно ножик с историей у нас путём удара в сердце стартует ритуал
*/

/obj/item/material/knife/heretic
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/cult.dmi'
	icon_state = "render"
	base_parry_chance = 30
	applies_material_colour = FALSE
	applies_material_name = FALSE

/*
Наши универсальные силы
*/

/datum/power/heretic/create_circle
	name = "Create Transmutation Circle"
	desc = "Создаёт алхимический круг, необходимый для проведения всех трансмутаций."
	knowledgecost = 0
	verbpath = /mob/proc/create_circle

/datum/power/heretic/summon_codex
	name = "Transmutation: Codex Cicatrix"
	desc = "Создаёт в случае отсутствия или призывает уже имеющийся Кодекс, необходимый для проведения ряда ритуалов."
	knowledgecost = 0
	verbpath = /mob/proc/summon_codex

/datum/power/heretic/blade
	name = "Transmutation: Eldrich Blade"
	desc = "Превращает нож в ритуальный кинжал."
	knowledgecost = 0
	verbpath = /mob/proc/summon_blade

/datum/power/heretic/choose_path
	name = "Choose Path of Enlightment"
	desc = "Выберете Путь Просветления. Это действие нельзя отменить, выбирайте с умом."
	knowledgecost = 0
	verbpath = /mob/proc/choose_path
