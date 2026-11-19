/mob/living/simple_animal/heretic_summon

	icon = 'mods/heretic/icons/mob/heretic_mobs.dmi'

	universal_speak = FALSE
	universal_understand = TRUE
	min_gas = null
	max_gas = null
	minbodytemp = 0
	faction = "heretic"
	supernatural = 1
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	mob_swap_flags = HUMAN|SIMPLE_ANIMAL|SLIME|MONKEY
	mob_push_flags = ALLMOBS
	bleed_colour = "#331111"

	meat_type =     null
	meat_amount =   0
	bone_material = null
	bone_amount =   0
	skin_material = null
	skin_amount =   0

	harm_intent_damage = 0
	natural_weapon = /obj/item/natural_weapon/bite

	var/list/summons_spells = list()

/mob/living/simple_animal/heretic_summon/hud_type = /datum/hud/heretic_summon

/datum/hud/heretic_summon/FinalizeInstantiation()
	var/summontype

	if(istype(mymob,/mob/living/simple_animal/construct/armoured) || istype(mymob,/mob/living/simple_animal/construct/behemoth))
		summontype = "juggernaut"
	else if(istype(mymob,/mob/living/simple_animal/construct/builder))
		summontype = "artificer"
	else if(istype(mymob,/mob/living/simple_animal/construct/wraith))
		summontype = "wraith"
	else if(istype(mymob,/mob/living/simple_animal/construct/harvester))
		summontype = "harvester"

	if(summontype)
		mymob.fire = new /obj/screen()
		mymob.fire.icon = 'icons/mob/screen1_construct.dmi'
		mymob.fire.icon_state = "fire0"
		mymob.fire.SetName("fire")
		mymob.fire.screen_loc = ui_construct_fire // иконки остаются там же где и у конструктов

		mymob.healths = new /obj/screen()
		mymob.healths.icon = 'icons/mob/screen1_construct.dmi'
		mymob.healths.icon_state = "[summontype]_health0"
		mymob.healths.SetName("health")
		mymob.healths.screen_loc = ui_construct_health

		mymob.pullin = new /obj/screen()
		mymob.pullin.icon = 'icons/mob/screen1_construct.dmi'
		mymob.pullin.icon_state = "pull0"
		mymob.pullin.SetName("pull")
		mymob.pullin.screen_loc = ui_construct_pull

		mymob.zone_sel = new /obj/screen/zone_sel()
		mymob.zone_sel.icon = 'icons/mob/screen1_construct.dmi'
		mymob.zone_sel.ClearOverlays()
		mymob.zone_sel.AddOverlays(image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]"))

		mymob.purged = new /obj/screen()
		mymob.purged.icon = 'icons/mob/screen1_construct.dmi'
		mymob.purged.icon_state = "purge0"
		mymob.purged.SetName("purged")
		mymob.purged.screen_loc = ui_construct_purge

	mymob.client.screen = list()
	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged)
