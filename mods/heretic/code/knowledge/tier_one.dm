/*!
 * Tier 1 knowledge: Stealth and general utility
 */

/datum/heretic_knowledge/void_cloak
	name = "Void Cloak"
	desc = "Allows you to transmute a glass shard, a bedsheet, and any outer clothing item (such as armor or a suit jacket) \
		to create a Void Cloak. While the hood is down, the cloak functions as a focus and protects you from space. \
		While the hood is up, the cloak is completely invisible. It also provide decent armor and \
		has pockets which can hold one of your blades, various ritual components (such as organs), and small heretical trinkets."
	gain_text = "The Owl is the keeper of things that are not quite in practice, but in theory are. Many things are."
	required_atoms = list(
		/obj/item/material/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/storage/hooded/cultrobes/void)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/obj/obj_suit.dmi'
	research_tree_icon_state = "void_cloak"
	drafting_tier = 1

/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Allows you to transmute a pair of eyes, a candle, and a glass shard into an Eldritch Medallion. \
		The Eldritch Medallion grants you thermal vision while worn, and also functions as a focus."
	gain_text = "Piercing eyes guided them through the mundane. Neither darkness nor terror could stop them."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/material/shard = 1,
		/obj/item/flame/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/accessory/amulet/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"
	drafting_tier = 1

/datum/heretic_knowledge/phylactery
	name = "Phylactery of Damnation"
	desc = "Allows you to transmute a sheet of glass and a poppy into a Phylactery that can instantly draw blood, even from long distances. \
		Be warned, your target may still feel a prick."
	gain_text = "A tincture twisted into the shape of a bloodsucker vermin. \
		Whether it chose the shape for itself, or this is the humor of the sickened mind that conjured this vile implement into being is something best not pondered."
	required_atoms = list(
		/obj/item/stack/material/glass = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/phylactery)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"
	drafting_tier = 1

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Allows you to transmute a sheet of plasma and a diamond to create an Eldritch Coin. \
		The coin will open or close nearby doors when landing on heads and toggle their bolts \
		when landing on tails. If you insert the coin into an airlock, it will be consumed \
		to fry its electronics, opening the airlock permanently unless bolted. "
	gain_text = "The Mansus is a place of all sorts of sins. But greed held a special role."
	required_atoms = list(
		/obj/item/stack/material/diamond = 1,
		/obj/item/stack/material/phoron = 1,
	)
	result_atoms = list(/obj/item/material/coin/challenge/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/materials/coin.dmi'
	research_tree_icon_state = "syndie"
	drafting_tier = 1

/**
 * This allows heretics to choose if they want to rush all the influences and take them stealthily, or
 * Construct a codex and take what's left with more points.
 * Another downside to having the book is strip searches, which means that it's not just a free nab, at least until you get exposed - and when you do, you'll probably need the faster drawing speed.
 * Overall, it's a tradeoff between speed and stealth or power.
 */
/datum/heretic_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to transmute a book, any pen, and your pick from any carcass (animal or human), leather, or hide to create a Codex Cicatrix. \
		The Codex Cicatrix can be used when draining influences to gain additional knowledge, but comes at greater risk of being noticed. \
		It can also be used to draw and remove transmutation runes easier, and as a spell focus in a pinch."
	gain_text = "The occult leaves fragments of knowledge and power anywhere and everywhere. The Codex Cicatrix is one such example. \
		Within the leather-bound faces and age old pages, a path into the Mansus is revealed."
	required_atoms = list(
		/obj/item/book = 1,
		/obj/item/pen = 1,
		list(/obj/item/stack/material/leather, /obj/item/stack/animalhide, /mob/living/simple_animal/passive/mouse) = 1, // /mob/living,
	)
	result_atoms = list(/obj/item/book/codex_cicatrix)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 4
	drafting_tier = 1
	is_shop_only = TRUE
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "book"

	var/static/list/non_mob_bindings = typecacheof(list(
		/obj/item/stack/material/leather,
		/obj/item/stack/animalhide,
		/mob/living/simple_animal/passive/mouse,
	))

/datum/heretic_knowledge/codex_cicatrix/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/thingy in atoms)
		if(is_type_in_typecache(thingy, non_mob_bindings))
			selected_atoms += thingy
			return TRUE
		else if(isliving(thingy))
			var/mob/living/body = thingy
			if(body.stat != DEAD)
				continue
			selected_atoms += body
			return TRUE
	return FALSE

/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()
	// A golem or an android doesn't have skin!
	var/exterior_text = "skin"
	// If carbon, it's the limb. If not, it's the body.
	var/atom/movable/ripped_thing = body

	// We will check if it's a carbon's body.
	// If it is, we will damage a random bodypart, and check that bodypart for its body type, to select between 'skin' or 'exterior'.
	if(iscarbon(body))
		var/mob/living/carbon/carbody = body
		var/obj/item/organ/external/bodypart = pick(BP_ALL_LIMBS)
		ripped_thing = bodypart

		carbody.apply_damage(25, DAMAGE_BRUTE, bodypart, DAMAGE_FLAG_SHARP)
		if((bodypart.status & ORGAN_ROBOTIC))
			exterior_text = "exterior"
	else
		body.apply_damage(25, DAMAGE_BRUTE, DAMAGE_FLAG_SHARP)
		// If it is not a carbon mob, we will just check biotypes and damage it directly.
		if(issilicon(body))
			exterior_text = "exterior"

	// Procure book for flavor text. This is why we call parent at the end.
	var/obj/item/book/le_book = locate() in selected_atoms
	if(!le_book)
		stack_trace("Somehow, no book in codex cicatrix selected atoms! [english_list(selected_atoms)]")
	playsound(body, 'sound/items/poster_ripped.ogg', 100, TRUE)
	body.do_jitter()
	body.visible_message(SPAN_DANGER("An awful ripping sound is heard as [ripped_thing]'s [exterior_text] is ripped straight out, wrapping around [le_book || "the book"], turning into an eldritch shade of blue!"))
	return ..()

/**
 * Warren King's Welcome
 * Offers an alternative way besides stealing an ID or visiting the HoP to gain access to maintenance
 * Additionally changes all nearby airlock's access's to ACCESS_HERETIC
 */
/datum/heretic_knowledge/bookworm
	name = "Warren King's Welcome"
	desc = "Allows you to transmute 10 cable pieces, a piece of paper, and a multitool to brand nearby ID cards and airlocks. \
		Branded ID cards will gain access to maintenance, external airlocks, as well to branded airlocks. \
		Branded airlocks will only be accessible by those with a branded ID card."
	gain_text = "Gnawed into vicious-stained fingerbones, my grim invitation snaps my nauseous and clouded mind towards the heavy-set door. \
		Slowly, the light dances between a crawling darkness, blanketing the fetid promenade with infinite machinations. \
		But the King will soon take his pound of flesh. Even here, the taxman takes their cut. For there are a thousands mouths to feed."
	required_atoms = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/paper = 1,
		/obj/item/device/multitool = 1,
	)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 3
	drafting_tier = 1
	research_tree_icon_path = 'icons/obj/tools/card.dmi'
	research_tree_icon_state = "emag"

/datum/heretic_knowledge/bookworm/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/used_id in atoms)
		selected_atoms += used_id
	var/obj/item/card/user_card = user.GetIdCard()
	if(user_card)
		selected_atoms += user_card

/datum/heretic_knowledge/bookworm/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/improved_id in selected_atoms)
		improved_id.access.Add(list(access_maint_tunnels, access_external_airlocks, access_heretic))
		selected_atoms -= improved_id
	for(var/obj/machinery/door/airlock/door in view(7, loc))
		door.req_access = list(access_heretic)
		door.wires.UpdateCut(AIRLOCK_WIRE_AI_CONTROL, mended = FALSE)
		new /obj/sparks(door.loc)

	return TRUE


/*
	SierraBay add - recipes not ported from TG
*/

/datum/heretic_knowledge/fungoid_heart
	name = "Fungoid Heart"
	desc = "Allows you to transmute a mushroom and a pool of blood to create a Fungoid Heart. \
		The heart can be activated like grenade to spawn an auxiliary blob nucleus \
		when timer expires. Blob hostile to everyone, including summoner. "
	gain_text = "Just a small reflection of that force of nature that is trying to eat away at the foundations of the universe."
	required_atoms = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom = 1,
		/obj/decal/cleanable/blood = 1
	)
	result_atoms = list(/obj/item/grenade/spawnergrenade/blob)
	cost = 1
	research_tree_icon_path = 'icons/mob/blob.dmi'
	research_tree_icon_state = "core_sample_2"
	drafting_tier = 1

/datum/heretic_knowledge/stitcher
	name = "Visitor's Gloves"
	desc = "Allows you to transmute a latex gloves, meat and space cleaner bottle into Visitor's Gloves. \
		This gloves can be used in manner of foresinc ones, but can mimic fingerprints of someone, which blood is on them."
	gain_text = "Uncanny Visitor, which always been here. Always been around you. Turn around. He's here."
	required_atoms = list(
		/obj/item/clothing/gloves/latex = 1,
		/obj/item/reagent_containers/food/snacks/meat = 1,
		/obj/item/reagent_containers/spray/cleaner = 1
	)
	result_atoms = list(/obj/item/clothing/gloves/forensic/stitcher)
	cost = 1
	research_tree_icon_path = 'mods/heretic/icons/eldritch.dmi'
	research_tree_icon_state = "spacehand_left"
	drafting_tier = 1
