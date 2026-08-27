/*
TIER ONE
*/

/datum/power/heretic/feather_fall
	path = HERETIC_POWER_RIDDLE
	tier = HERETIC_TIER_ONE
	name = "Feather Fall"
	desc = "Пассивная. Вместо урона от падения вы получаете урон по стамине."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 0
	verbpath = /mob/proc/feather_fall

/mob/proc/feather_fall()

/datum/power/heretic/riddle_of_man
	path = HERETIC_POWER_RIDDLE
	tier = HERETIC_TIER_ONE
	name = "Riddle of Man"
	desc = "Цель на короткое время страдает от дезориентации и говорит чужим голосом и языком, который не знает."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/riddle_of_man

/mob/proc/riddle_of_man()

/*
TIER TWO
*/

/datum/power/heretic/hysteria
	path = HERETIC_POWER_RIDDLE
	tier = HERETIC_TIER_TWO
	name = "Hysteria"
	desc = "Ценой урона мозгу во время действия заклинания, еретик получает уменьшенный урон от атак, его рейтинг силы повышается, а скорость собственных атак и передвижения увеличены."
	helptext = "Базированный сандевистан, только красный."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/hysteria

/mob/proc/hysteria()

/datum/power/heretic/butterfly
	path = HERETIC_POWER_RIDDLE
	tier = HERETIC_TIER_TWO
	name = "Passage"
	desc = "throw a spell towards an area and teleport to it."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/butterfly

/mob/proc/butterfly()

/*
TIER THREE
*/

/datum/power/heretic/cards
	path = HERETIC_POWER_RIDDLE
	tier = HERETIC_TIER_THREE
	name = "Deck of Cards"
	desc = "В зависимости от выпавшей карты накладываем рандомный эффект."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/riddle_of_cards

/mob/proc/riddle_of_cards()
