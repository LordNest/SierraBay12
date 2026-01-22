/*
TIER ONE
*/

/spell/targeted/heal_target/hunter
	name = "Cure Light Wounds"
	desc = "a rudimentary spell used mainly by wizards to heal papercuts. Does not require wizard garb."
	feedback = "CL"
	school = "transmutation"
	charge_max = 20 SECONDS
	spell_flags = INCLUDEUSER | NO_SOMATIC
	invocation = "Di'Nath!"
	invocation_type = SpI_SHOUT
	range = 2
	max_targets = 1

	hud_state = "friendly"

	var/mob/living/carbon/human/C = src
	to_chat(C, "<span class='notice'>Energy rushes through us.  [C.lying ? "We arise." : ""]</span>")
	C.set_stat(CONSCIOUS)
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetWeakened(0)
	C.setHalLoss(0)
	C.lying = 0
	C.blinded = 0
	C.eye_blind = 0
	C.eye_blurry = 0
	C.ear_deaf = 0
	C.ear_damage = 0
	C.clear_confused()
	C.sleeping = 0
//	C.reagents.add_reagent("toxin", 10)
	C.reagents.add_reagent("synaptizine", 10)

	return TRUE

//////////////////////////////////////////////////////

/spell/hunter_whiste
	name = "Huntsman Whiste"
	desc = "Все лампы в зоне видимости с треском перегорают, а персональные источники света отключаются."

/*
TIER TWO
*/

/spell/targeted/huntsman_instincts
	name = "Huntsman Instincts"
	desc = "Пассивная возможность слышать шаги за стенами, а также отсутствие ФОВ в броне и мехах."
	knowledgecost = 1
	verbpath = /mob/proc/huntsman_instinct

/mob/proc/huntsman_instinct()
	set category = "heretic"
	set name = "Adrenaline Surge (20)"
	set desc = "Removes all stuns instantly, and reduces future stuns."

	var/mob/living/carbon/human/C = src
	C.resomi_sonar_ping()

//////////////////////////////////////////////////////

/spell/mark_recall/huntsman_return
	name = "Huntsman Return"
	desc = "Возвращает вас к последнему фонарю из которого вы перемещались в сон."
	feedback = "MK"
	school = "conjuration"
	charge_max = 600 //1 minutes for how OP this shit is (apparently not as op as I thought)
	spell_flags = Z2NOCAST
	invocation = "Re-Alki R'natha."
	invocation_type = SpI_WHISPER
	cooldown_min = 300

	smoke_amt = 1
	smoke_spread = 5

	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 4, Sp_POWER = 1)

	cast_sound = 'sound/effects/teleport.ogg'
	hud_state = "wiz_mark"
	var/mark = null

/spell/mark_recall/choose_targets()
	if(!mark)
		return list("magical fairy dust") //because why not
	else
		return list(mark)

/spell/mark_recall/cast(list/targets,mob/user)
	if(!length(targets))
		return 0
	var/target = targets[1]
	if(istext(target))
		mark = new /obj/cleanable/wizard_mark(get_turf(user),src)
		return 1
	if(!istype(target,/obj)) //something went wrong
		return 0
	var/turf/T = get_turf(target)
	if(!T)
		return 0
	user.forceMove(T)
	..()

/spell/mark_recall/empower_spell()
	if(!..())
		return 0

	spell_flags = NO_SOMATIC

	return "You will always be able to cast this spell, even while unconscious or handcuffed."

/obj/cleanable/wizard_mark/lanthern
	name = "\improper Mark of the Wizard"
	desc = "A strange rune said to be made by wizards. Or its just some shmuck playing with crayons again."
	icon = 'icons/obj/rune.dmi'
	icon_state = "wizard_mark"

	anchored = TRUE
	unacidable = TRUE
	layer = TURF_LAYER

	var/spell/mark_recall/spell

/obj/cleanable/wizard_mark/New(newloc,mrspell)
	..()
	spell = mrspell

/obj/cleanable/wizard_mark/Destroy()
	spell.mark = null //dereference pls.
	spell = null
	..()

/obj/cleanable/wizard_mark/attack_hand(mob/user)
	if(user == spell.holder)
		user.visible_message("\The [user] mutters an incantation and \the [src] disappears!")
		qdel(src)
	..()


/obj/cleanable/wizard_mark/use_tool(obj/item/tool, mob/user, list/click_params)
	// Null Rod or Spell Book - Remove mark
	if (is_type_in_list(tool, list(/obj/item/nullrod, /obj/item/spellbook)))
		user.visible_message(
			SPAN_NOTICE("\The [user] waves \a [tool] over \the [src], and it fades away."),
			SPAN_NOTICE("You wave \the [tool] over \the [src], and it fades away.")
		)
		qdel(src)
		return TRUE

	return ..()

/*
TIER THREE
*/

/spell/targeted/ethereal_jaunt/hunter
	name = "Miststep"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	feedback = "EJ"
	school = "transmutation"
	charge_max = 30 SECONDS
	spell_flags = Z2NOCAST | INCLUDEUSER
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	max_targets = 1
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 4, Sp_POWER = 3)
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	duration = 5 SECONDS

	hud_state = "wiz_jaunt"
