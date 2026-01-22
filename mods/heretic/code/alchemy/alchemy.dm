// Full Metal Alchemist, how are you?
// Мастер спелл для руны трансмутаций, где аналогично ТГ будет происходить основной блудняк

/datum/power/heretic/create_circle
	name = "Create Transmutation Circle"
	desc = "Создаёт алхимический круг, необходимый для проведения всех трансмутаций."
	knowledgecost = 0
	ability_icon_state = "ling_absorb_dna"
	power_category = HERETIC_POWER_GENERAL
	verbpath = /mob/proc/create_circle

/mob/proc/create_circle()
	set category = "Cult Magic"
	set name = "Rune: Convert"

	make_rune(/obj/rune/alchemy, tome_required = 1)

/// Почему руна? Потому что часть кода взаимодействует именно с ней как с типом, поэтому мы пристроимся рядом с культом, просто заменив иконки.

/obj/rune/alchemy
	name = "rune"
	desc = "A strange collection of symbols drawn in blood."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune3"


/datum/alchemy
	var/name = null
	var/desc = null
	// Chosen path for our alchemy recipe
	var/list/path = HERETIC_POWER_GENERAL
	var/list/components = list()

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

/mob/proc/summon_codex

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
