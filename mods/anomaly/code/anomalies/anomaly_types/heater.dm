/obj/anomaly/heater
	name = "Refractions of light"
	anomaly_tag = "Heater"
	with_sound = FALSE
	can_born_artefacts = TRUE
	//Длинна эффекта подогрева
	effect_time = 30 SECONDS
	effect_type = LONG_ANOMALY_EFFECT
	cooldown_time = 30 SECONDS
	detection_icon_state = "hot_anomaly"
	iniciators = list(
		/mob/living
	)
	artefacts = list(
		/obj/item/artefact/zjar = 1
	)
	artefact_spawn_chance = 5
	chance_to_be_detected = 140
	time_between_effects = 0.5 SECOND


/obj/anomaly/heater/Initialize()
	. = ..()
	for(var/obj/anomaly/part/choosed_part in list_of_parts)
		LAZYADD(effected_turfs, get_turf(choosed_part))
	LAZYADD(effected_turfs, get_turf(src))


//Хитер начинает долгую обработку
/obj/anomaly/heater/process_long_effect()
	heat_everybody_around()
	start_processing_long_effect()


/obj/anomaly/heater/proc/heat_everybody_around()
	for(var/turf/turfs in effected_turfs)
		for(var/mob/living/victim in turfs)
			victim.bodytemperature += 2


/obj/anomaly/heater/Crossed(atom/movable/O)
	if(currently_active)
		return
	if(currently_charging_after_activation)
		return
	if(can_be_activated(O))
		activate_anomaly()
	return
