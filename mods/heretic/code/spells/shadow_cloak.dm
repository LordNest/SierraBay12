/spell/shadow_cloak
	name = "Shadow Cloak"
	desc = "Engulf yourself into the cloak of shadows"
	school = "heretical"
	feedback = "ra"
	invocation_type = SpI_EMOTE
	invocation = "conjures a cloak of shadows around themselves."
	spell_flags = NEEDSFOCUS | HERETIC_CHECK
	charge_max = 180
	cooldown_min = 180
	cast_sound = 'sound/effects/snap.ogg'
	duration = 60
	hud_state = "invisibility"

/spell/shadow_cloak/choose_targets()
	return list(holder)

/spell/shadow_cloak/cast(list/targets, mob/user)
	var/obj/aura/shadow_cloak/A = new(user)
	addtimer(new Callback(A, TYPE_PROC_REF(/datum, Destroy)), duration SECONDS)

/obj/aura/shadow_cloak
	name = "shadow cloak"
	icon = 'mods/heretic/icons/effects/heretic_effects.dmi'
	icon_state = "curse"
	layer = ABOVE_HUMAN_LAYER

/obj/aura/shadow_cloak/added_to(mob/living/L)
	..()
	var/mob/living/carbon/human/H = user
	H.add_cloaking_source(src)
	to_chat(L,SPAN_NOTICE("A cloak of shadows envelops you."))

/obj/aura/shadow_cloak/removed()
	var/mob/living/carbon/human/H = user
	H.remove_cloaking_source(src)
	H.update_icon()
	to_chat(H, SPAN_WARNING("Your concealing aura disappears."))
	..()
