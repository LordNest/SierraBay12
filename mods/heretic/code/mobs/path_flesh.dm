/mob/living/simple_animal/flesh_construct
/* 	name = "cortical flesh_construct"
	real_name = "cortical flesh_construct"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	// emote_hear = list("chirrups")
	response_help  = "pokes"
	response_disarm = "prods"
	response_harm   = "stomps on"
	icon_state = "brainslug"
	item_state = "voxslug" // For the lack of a better sprite...
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = I_HURT
	status_flags = CANPUSH
	natural_weapon = /obj/item/natural_weapon/bite/weak
	friendly = "prods"
	pass_flags = PASS_FLAG_TABLE
	universal_understand = TRUE
	mob_size = MOB_SMALL
	can_escape = TRUE
	density = FALSE

	bleed_colour = "#816e12"

	var/static/list/chemical_types = list(
		"bicaridine" = /datum/reagent/bicaridine,
		"hyperzine" =  /datum/reagent/hyperzine,
		"tramadol" =   /datum/reagent/opiate/tramadol,
		"dermaline" =  /datum/reagent/dermaline,
		"peridaxon" =  /datum/reagent/peridaxon,
		"inaprovaline" =  /datum/reagent/inaprovaline,
		"dylovene" =  /datum/reagent/dylovene
	)

	var/generation = 1
	var/static/list/flesh_construct_names = list(
		"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
		"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
		)

	var/image/aura_image
	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/truename                            // Name used for brainworm-speak.
	var/controlling                         // Used in human death check.
	var/docile = FALSE                      // Sugar can stop flesh_constructs from acting.
	var/has_reproduced                      // Whether or not the flesh_construct has reproduced, for objective purposes.
	var/roundstart                          // Whether or not this flesh_construct has been mapped and should not look for a player initially.
	var/neutered                            // 'flesh_construct lite' mode - fewer powers, less hostile to the host.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.

/mob/living/simple_animal/flesh_construct/roundstart
	roundstart = TRUE

/mob/living/simple_animal/flesh_construct/neutered
	neutered = TRUE

/mob/living/simple_animal/flesh_construct/Login()
	. = ..()
	if(client)
		client.screen |= hud_elements
		client.screen |= hud_intent_selector
	if(mind && !neutered)
		GLOB.flesh_constructs.add_antagonist(mind)

/mob/living/simple_animal/flesh_construct/Logout()
	. = ..()
	if(client)
		client.screen -= hud_elements
		client.screen -= hud_intent_selector

/mob/living/simple_animal/flesh_construct/Initialize(mapload, gen=1)

	hud_intent_selector =  new
	hud_inject_chemicals = new
	hud_leave_host =       new
	hud_elements = list(
		hud_inject_chemicals,
		hud_leave_host
	)
	if(!neutered)
		hud_toggle_control = new
		hud_elements += hud_toggle_control

	. = ..()

	add_language(LANGUAGE_flesh_construct_GLOBAL)
	verbs += /mob/living/proc/ventcrawl
	verbs += /mob/living/proc/hide

	generation = gen
	set_flesh_construct_name()

	if(!roundstart)
		request_player()

	aura_image = create_aura_image(src)
	aura_image.color = "#aaffaa"
	aura_image.blend_mode = BLEND_SUBTRACT
	aura_image.alpha = 125
	aura_image.SetTransform(scale = 0.33)

/mob/living/simple_animal/flesh_construct/death(gibbed, deathmessage, show_dead_message)
	if(aura_image)
		destroy_aura_image(aura_image)
		aura_image = null
	. = ..()

/mob/living/simple_animal/flesh_construct/Destroy()
	if(aura_image)
		destroy_aura_image(aura_image)
		aura_image = null
	if(client)
		client.screen -= hud_elements
		client.screen -= hud_intent_selector
	QDEL_NULL_LIST(hud_elements)
	QDEL_NULL(hud_intent_selector)
	hud_toggle_control =   null
	hud_inject_chemicals = null
	hud_leave_host =       null
	. = ..()

/mob/living/simple_animal/flesh_construct/proc/set_flesh_construct_name()
	truename = "[flesh_construct_names[min(generation, length(flesh_construct_names))]] [random_id("flesh_construct[generation]", 1000, 9999)]"

/mob/living/simple_animal/flesh_construct/Life()

	sdisabilities = 0
	if(host)
		blinded = host.blinded
		eye_blind = host.eye_blind
		eye_blurry = host.eye_blurry
		if(host.sdisabilities & BLINDED)
			sdisabilities |= BLINDED
		if(host.sdisabilities & DEAFENED)
			sdisabilities |= DEAFENED
	else
		blinded =    FALSE
		eye_blind =  0
		eye_blurry = 0

	. = ..()
	if(!.)
		return FALSE

	if(host)

		if(!stat && !host.stat)

			if(host.reagents.has_reagent(/datum/reagent/sugar))
				if(!docile)
					if(controlling)
						to_chat(host, SPAN_NOTICE("You feel the soporific flow of sugar in your host's blood, lulling you into docility."))
					else
						to_chat(src, SPAN_NOTICE("You feel the soporific flow of sugar in your host's blood, lulling you into docility."))
					docile = 1
			else
				if(docile)
					if(controlling)
						to_chat(host, SPAN_NOTICE("You shake off your lethargy as the sugar leaves your host's blood."))
					else
						to_chat(src, SPAN_NOTICE("You shake off your lethargy as the sugar leaves your host's blood."))
					docile = 0

			if(chemicals < 250 && host.nutrition >= (neutered ? 200 : 50))
				host.nutrition--
				chemicals++

			if(controlling)

				if(neutered)
					host.release_control()
					return

				if(docile)
					to_chat(host, SPAN_NOTICE("You are feeling far too docile to continue controlling your host..."))
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(0.1)

				if(prob(host.getBrainLoss()/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_v","gasp"))]")

/mob/living/simple_animal/flesh_construct/Stat()
	. = ..()
	statpanel("Status")

	if(evacuation_controller)
		var/eta_status = evacuation_controller.get_status_panel_eta()
		if(eta_status)
			stat(null, eta_status)

	if (client.statpanel == "Status")
		stat("Chemicals", chemicals)

/mob/living/simple_animal/flesh_construct/proc/detatch()

	if(!host || !controlling) return

	if(istype(host,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
		head.implants -= src

	controlling = 0

	host.remove_language(LANGUAGE_flesh_construct_GLOBAL)
	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae

	if(host_brain)

		// these are here so bans and multikey warnings are not triggered on the wrong people when ckey is changed.
		// computer_id and IP are not updated magically on their own in offline mobs -walter0o

		// host -> self
		var/h2s_id = host.computer_id
		var/h2s_ip= host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		src.ckey = host.ckey

		if(!src.computer_id)
			src.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			src.lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip= host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		host.ckey = host_brain.ckey

		if(!host.computer_id)
			host.computer_id = b2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = b2h_ip

	qdel(host_brain)

#define COLOR_flesh_construct_RED "#ff5555"
/mob/living/simple_animal/flesh_construct/proc/set_ability_cooldown(amt)
	last_special = world.time + amt
	for(var/obj/thing in hud_elements)
		thing.color = COLOR_flesh_construct_RED
	addtimer(new Callback(src, TYPE_PROC_REF(/mob/living/simple_animal/flesh_construct, reset_ui_callback)), amt)
#undef COLOR_flesh_construct_RED

//Procs for grabbing players.
/mob/living/simple_animal/flesh_construct/proc/request_player()
	var/datum/ghosttrap/G = get_ghost_trap("cortical flesh_construct")
	G.request_player(src, "A cortical flesh_construct needs a player.")

/mob/living/simple_animal/flesh_construct/flash_eyes(intensity, override_blindness_check, affect_silicon, visual, type)
	intensity *= 1.5
	. = ..()
 */
