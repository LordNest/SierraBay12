/spell/shadow_cloak
	name = "Shadow Cloak"
	desc = "Engulf yourself into the cloak of shadows"
	school = "heretical"
	feedback = "ra"
	invocation_type = SpI_EMOTE
	invocation = "conjures a cloak of shadows around themselves."
	spell_flags = NEEDSCLOTHES | HERETIC_CHECK
	charge_max = 300
	cooldown_min = 100
	level_max = list(Sp_TOTAL = 2, Sp_SPEED = 2, Sp_POWER = 0)
	cast_sound = 'sound/effects/snap.ogg'
	duration = 60
	hud_state = "invisibility"

/spell/shadow_cloak/choose_targets()
	return list(holder)

/spell/shadow_cloak/cast(list/targets, mob/user)
	var/obj/aura/shadow_cloak/A = new(user)
	QDEL_IN(A,duration)

/obj/aura/shadow_cloak
	name = "shadow cloak"
	icon = 'mods/heretic/icons/effects/heretic_effects.dmi'
	icon_state = "curse"
	layer = ABOVE_HUMAN_LAYER

/obj/aura/shadow_cloak/added_to(mob/living/L)
	..()
	to_chat(L,SPAN_NOTICE("A cloak of shadows envelops you."))

/obj/aura/shadow_cloak/removed()
	to_chat(user, SPAN_WARNING("Your concealing aura disappears."))
	..()
