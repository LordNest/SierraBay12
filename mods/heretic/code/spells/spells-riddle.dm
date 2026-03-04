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
				)

/*
TIER ONE
*/

/spell/targeted/feather_fall
	tier = HERETIC_TIER_ONE
	name = "Feather Fall"
	desc = "Пассивная. Вместо урона от падения вы получаете урон по стамине."
	school = "heretical"


/spell/targeted/riddle_of_man
	tier = HERETIC_TIER_ONE
	name = "Riddle of Man"
	desc = "Цель на короткое время страдает от дезориентации и говорит чужим голосом и языком, который не знает."
	school = "heretical"

/*
TIER TWO
*/

/spell/targeted/hysteria
	name = "Hysteria"
	desc = "Ценой урона мозгу во время действия заклинания, еретик получает уменьшенный урон от атак, его рейтинг силы повышается, а скорость собственных атак и передвижения увеличены."
	school = "heretical"

/spell/targeted/projectile/dumbfire/passage/butterfly
	name = "Passage"
	desc = "throw a spell towards an area and teleport to it."
	feedback = "PA"
	proj_type = /obj/item/projectile/spell_projectile/passage


	school = "heretical"
	charge_max = 250
	spell_flags = 0
	invocation = "A'YASAMA"
	invocation_type = SpI_SHOUT
	range = 15


	level_max = list(Sp_TOTAL = 1, Sp_SPEED = 0, Sp_POWER = 1)
	spell_flags = NEEDSCLOTHES
	duration = 15

	proj_step_delay = 1

	hud_state = "gen_project"
	cast_sound = 'sound/magic/lightning_bolt.ogg'

/*
TIER THREE
*/

/*
/datum/power/heretic/miststep
	name = "Miststep"
	desc = "Вы становитесь невидимы и можете проходить сквозь стены на короткий промежуток времени."


*/
