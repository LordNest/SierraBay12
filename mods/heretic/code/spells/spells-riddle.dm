/* /obj/item/spellbook/heretic/riddle
	spellbook_type = /datum/spellbook/heretic/riddle

/datum/spellbook/heretic/riddle
	name = "\improper Puzzled Cookbook"
	feedback = "RD"
	desc = "It smells like an air freshener."
	book_desc = "Summons, nature, and a bit o' healin."
	title = "Druidic Guide on how to be smug about nature"
	title_desc = "Buy spells using your available spell slots. Artefacts may also be bought however their cost is permanent."
	book_flags = NOREVERT|NO_LOCKING
	max_uses = 6

	spells = list(/spell/targeted/heal_target = 					1,
				/spell/targeted/heal_target/sacrifice = 			1,
				/spell/aoe_turf/conjure/mirage = 					1,
				/spell/aoe_turf/conjure/summon/bats = 				1,
				/spell/targeted/equip_item/party_hardy = 			1,
				/spell/targeted/equip_item/seed = 					1,
				/spell/targeted/shapeshift/avian = 					1,
				/spell/aoe_turf/disable_tech = 						1,
				/spell/hand/charges/entangle = 						1,
				/spell/aoe_turf/conjure/grove/sanctuary = 			1,
				/spell/aoe_turf/knock = 							1,
				/spell/area_teleport = 								2,
				/spell/portal_teleport = 							2,
				/spell/noclothes = 									1,
				/obj/structure/closet/wizard/souls = 				1,
				/obj/item/magic_rock = 						1,
				/obj/item/summoning_stone = 					2,
				/obj/item/contract/wizard/telepathy = 		1,
				/obj/item/contract/apprentice = 				1
				) */

/*
TIER ONE
*/

/datum/power/heretic/riddle
	path = HERETIC_POWER_RIDDLE
	make_hud_button = 1

/datum/power/heretic/riddle/feather_fall
	tier = HERETIC_TIER_ONE
	name = "Feather Fall"
	desc = "Пассивная. Вместо урона от падения вы получаете урон по стамине."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 0
	verbpath = /mob/proc/feather_fall

/mob/proc/feather_fall()

/datum/power/heretic/riddle/riddle_of_man
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

/datum/power/heretic/riddle/hysteria
	name = "Hysteria"
	desc = "Ценой урона мозгу во время действия заклинания, еретик получает уменьшенный урон от атак, его рейтинг силы повышается, а скорость собственных атак и передвижения увеличены."
	helptext = "Базированный сандевистан, только красный."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/hysteria

/mob/proc/hysteria()

/datum/power/heretic/riddle/butterfly
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

/datum/power/heretic/riddle/cards
	name = "Deck of Cards"
	desc = "В зависимости от выпавшей карты накладываем рандомный эффект."
	ability_icon_state = "surge"
	knowledgecost = 1
	make_hud_button = 1
	verbpath = /mob/proc/riddle_of_cards

/mob/proc/riddle_of_cards()
