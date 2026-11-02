/datum/weather_manager/swamp
	weather_name = "Туман"
	weather_turf_type = /obj/weather/swamp
	stages = list(
		"calm",
	)
	can_blowout = FALSE

/datum/weather_manager/swamp/change_visual_weather(force_state = FALSE, override_parameters = TRUE, monitor = TRUE, sound = FALSE, blowout_status = FALSE, new_icon_state = "void")
	var/possible_stages = stages.Copy()
	LAZYREMOVE(possible_stages, current_stage)
	if(force_state)
		current_stage = force_state
	else
		current_stage = pick(possible_stages)
	if(override_parameters)
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = new_icon_state
			weather.play_monitor_effect = monitor
			weather.play_sound = sound
			weather.blowout_status = blowout_status
			weather.update()
	else if(current_stage == "calm")
		for(var/obj/weather/weather in connected_weather_turfs)
			weather.icon_state = "void"
			weather.play_monitor_effect = TRUE
			weather.play_sound = TRUE
			weather.update()

/obj/weather/swamp/flick_weather_icon(state)
	flick("[icon_state]_to_[state]", src)

// Туман оккупирован mods/heretic для нужд карт подпространств еретика. В случае релиза Саргаса - переписать

//Туман
/obj/weather/swamp
	icon_state = "mist1"
	icon = 'mods/weather/icons/weather_effects.dmi'
	recommended_weather_manager = /datum/weather_manager/swamp
	must_react_at_enter = TRUE
	sound_type = list(
		'sound/effects/wind/tundra2.ogg'
	)
	blowout_icon_state = "snow_blowout"
	invisibility = INVISIBILITY_ABSTRACT // Туманная погода только накладывает оверлей


//Эффект тумана на экране
/obj/screen/fullscreen/swamp_effect
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "passage5"
	layer = BLIND_LAYER
	scale_to_view = TRUE


/obj/weather/swamp/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("swamp_monitor", /obj/screen/fullscreen/swamp_effect)
	//Логируем пользователя в глобальный список

/obj/weather/swamp/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("swamp_monitor")

//Туман легкий
/obj/weather/swamp/light
	icon_state = "mist0"

//Эффект тумана на экране
/obj/screen/fullscreen/swamp_effect/light
	icon_state = "passage3"

/obj/weather/swamp/light/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("swamp_monitor", /obj/screen/fullscreen/swamp_effect/light)
	//Логируем пользователя в глобальный список

/obj/weather/swamp/light/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("swamp_monitor")

//Туман тяжелый
/obj/weather/swamp/hard
	icon_state = "mist2"

//Эффект тумана на экране
/obj/screen/fullscreen/swamp_effect/hard
	icon_state = "passage7"

/obj/weather/swamp/hard/add_monitor_effect(mob/living/input_mob)
	input_mob.overlay_fullscreen("swamp_monitor", /obj/screen/fullscreen/swamp_effect/hard)
	//Логируем пользователя в глобальный список

/obj/weather/swamp/hard/remove_monitor_effect(mob/living/input_mob)
	input_mob.clear_fullscreen("swamp_monitor")
