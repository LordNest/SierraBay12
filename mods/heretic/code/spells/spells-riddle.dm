/*
TIER ONE
*/

/spell/targeted/feather_fall
	name = "Feather Fall"
	desc = "Пассивная. Вместо урона от падения вы получаете урон по стамине."



/spell/targeted/riddle_of_man
	name = "Riddle of Man"
	desc = "Цель на короткое время страдает от дезориентации и говорит чужим голосом и языком, который не знает."


/*
TIER TWO
*/

/spell/targeted/hysteria
	name = "Hysteria"
	desc = "Ценой урона мозгу во время действия заклинания, еретик получает уменьшенный урон от атак, его рейтинг силы повышается, а скорость собственных атак и передвижения увеличены."

/spell/targeted/projectile/dumbfire/passage/butterfly
	name = "Passage"
	desc = "throw a spell towards an area and teleport to it."
	feedback = "PA"
	proj_type = /obj/item/projectile/spell_projectile/passage


	school = "conjuration"
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
	knowledgecost = 1
	verbpath = /mob/proc/create_circle
*/
