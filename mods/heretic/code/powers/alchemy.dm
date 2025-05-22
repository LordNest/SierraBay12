// Full Metal Alchemist, how are you?
// Мастер спелл для руны трансмутаций, где аналогично ТГ будет происходить основной блудняк

/datum/power/heretic/create_circle
	name = "Create Transmutation Circle"
	desc = "Создаёт алхимический круг, необходимый для проведения всех трансмутаций."
	knowledgecost = 0
	ability_icon_state = "ling_absorb_dna"
	genomecost = 0
	power_category = HERETIC_POWER_GENERAL
	verbpath = /mob/living/proc/create_circle

/mob/proc/create_circle()
	set category = "Cult Magic"
	set name = "Rune: Convert"

	make_rune(/obj/rune/alchemy, tome_required = 1)

/// Почему руна? Потому что часть кода взаимодействует именно с ней как с типом, поэтому мы пристроимся рядом с культом, просто заменив иконки.

/obj/rune/alchemy
	name = "rune"
	desc = "A strange collection of symbols drawn in blood."
	icon = 'icons/effects/uristrunes.dmi'
	icon_state = "blank"
