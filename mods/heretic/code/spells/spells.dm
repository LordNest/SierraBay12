// Отсюда наш антаг диктует свою волю галактическому сообществу.
// Может реворкнем?
// Обязательно реворкнем. И не раз. Но потом.

#define HERETIC_TIER_ONE   1
#define HERETIC_TIER_TWO   2
#define HERETIC_TIER_THREE 3
#define HERETIC_TIER_FOUR  4

/spell

	var/tier = null

/obj/screen/ability/spell/heretic
	icon = 'mods/heretic/icons/heretic_powers.dmi'
	icon_state = "heretic_spell_base"
	maptext_x = 3
	background_base_state = "heretic"

// Да, мы работаем как книжка у нас в голове

/obj/item/spellbook/heretic
	spellbook_type = /datum/spellbook/heretic

	name = "heretic codex"
	desc = "Technical item for represrenting heretic connection to the otherwordly entites. If you see that, report to the dev team"
	icon = 'icons/obj/library.dmi'

/datum/spellbook/heretic
	name = "\improper Codex Cicatrix"
	desc = "The legendary book of spells of the wizard."
	book_desc = "Holds information on the various tomes available to a wizard"

	spells = list(/datum/spellbook/heretic/flesh = 1,
				/datum/spellbook/heretic/hunt = 1,
				/datum/spellbook/heretic/riddle = 1,
				/datum/spellbook/heretic/cosmos = 1
				)

// УИ уходит в небо

/obj/item/spellbook/heretic/interact(mob/user as mob)
	var/dat = null
	if(temp)
		dat = "[temp]<br><a href='byond://?src=\ref[src];temp=1'>Return</a>"
	else
		dat = "<center><h3>[spellbook.title]</h3><i>[spellbook.title_desc]</i><br>You have [uses] spell slot[uses > 1 ? "s" : ""] left.</center><br>"
		dat += "<center>[SPAN_COLOR("#ff33cc", "Requires Wizard Garb")]<br>[SPAN_COLOR("#ff6600", "Selectable Target")]<br>[SPAN_COLOR("#33cc33", "Spell Charge Type: Recharge, Sacrifice, Charges")]</center><br>"
		dat += "<center><b>To use a contract, first bind it to your soul, then give it to someone to sign. This will bind their soul to you.</b></center><br>"
		for(var/i in 1 to length(spellbook.spells))
			var/name = "" //name of target
			var/desc = "" //description of target
			var/info = "" //additional information
			if(ispath(spellbook.spells[i],/datum/spellbook))
				var/datum/spellbook/heretic/S = spellbook.spells[i]
				name = initial(S.name)
				desc = initial(S.book_desc)
				info = SPAN_COLOR("#ff33cc", "[initial(S.max_uses)] Spell Slots")
			else if(ispath(spellbook.spells[i],/obj))
				var/obj/O = spellbook.spells[i]
				name = "Ritual: [capitalize(initial(O.name))]" //because 99.99% of objects don't have capitals in them and it makes it look weird.
				desc = initial(O.desc)
			else if(ispath(spellbook.spells[i],/spell))
				var/spell/S = spellbook.spells[i]
				name = initial(S.name)
				desc = initial(S.desc)
				var/testing = initial(S.spell_flags)
				if(testing & NEEDSCLOTHES)
					info = SPAN_COLOR("#ff33cc", "W")
				var/type = ""
				switch(initial(S.charge_type))
					if(Sp_RECHARGE)
						type = "R"
					if(Sp_HOLDVAR)
						type = "S"
					if(Sp_CHARGES)
						type = "C"
				info += SPAN_COLOR("#33cc33", type)
			dat += "<a href='byond://?src=\ref[src];path=\ref[spellbook.spells[i]]'>[name]</a>"
			if(length(info))
				dat += " ([info])"
			dat += " ([spellbook.spells[spellbook.spells[i]]] spell slot[spellbook.spells[spellbook.spells[i]] > 1 ? "s" : "" ])"
			if(spellbook.book_flags & CAN_MAKE_CONTRACTS)
				dat += " <a href='byond://?src=\ref[src];path=\ref[spellbook.spells[i]];contract=1;'>Make Contract</a>"
			dat += "<br><i>[desc]</i><br><br>"
		dat += "<br>"
		dat += "<center><a href='byond://?src=\ref[src];reset=1'>Re-memorize your spellbook.</a></center>"
		if(!(spellbook.book_flags & NOREVERT))
			dat += "<center><a href='byond://?src=\ref[src];book=1'>Choose different spellbook.</a></center>"
	var/datum/browser/popup = new(user, "spellbook", name, 340, 540)
	popup.set_content(dat)
	popup.open()


/obj/item/spellbook/heretic/OnTopic(mob/living/carbon/human/user, href_list)
	if(href_list["lock"] && !(spellbook.book_flags & NO_LOCKING))
		if(spellbook.book_flags & LOCKED)
			spellbook.book_flags &= ~LOCKED
		else
			spellbook.book_flags |= LOCKED
		. = TOPIC_REFRESH

	else if(href_list["temp"])
		temp = null
		. = TOPIC_REFRESH

	else if(href_list["book"])
		if(initial(spellbook.max_uses) != spellbook.max_uses || uses != spellbook.max_uses)
			temp = "You've already purchased things using this spellbook!"
		else
			src.set_spellbook(/datum/spellbook)
			temp = "You have reverted back to the Book of Tomes."
		. = TOPIC_REFRESH

	else if(href_list["invest"])
		temp = invest()
		. = TOPIC_REFRESH

	else if(href_list["path"])
		var/path = locate(href_list["path"]) in spellbook.spells
		if(!path)
			return TOPIC_HANDLED
		if(uses < spellbook.spells[path])
			to_chat(user, SPAN_NOTICE("You do not have enough spell slots to purchase this."))
			return TOPIC_HANDLED
		if(ispath(path,/datum/spellbook))
			src.set_spellbook(path)
			temp = "You have chosen a new spellbook."
		else
			if(href_list["contract"])
				if(!(spellbook.book_flags & CAN_MAKE_CONTRACTS))
					return //no
				uses -= spellbook.spells[path]
				spellbook.max_uses -= spellbook.spells[path] //no basksies
				var/obj/O = new /obj/item/contract/boon(get_turf(user),path)
				temp = "You have purchased \the [O]."
			else
				if(ispath(path,/spell))
					temp = src.add_spell(user,path)
					if(temp)
						uses -= spellbook.spells[path]
				else
					var/obj/O = new path(get_turf(user))
					temp = "You have purchased \a [O]."
					uses -= spellbook.spells[path]
					spellbook.max_uses -= spellbook.spells[path]
					//finally give it a bit of an oomf
					playsound(get_turf(user),'sound/effects/phasein.ogg',50,1)
		. = TOPIC_REFRESH

	else if(href_list["reset"] && !(spellbook.book_flags & NOREVERT))
		var/area/map_template/wizard_station/A = get_area(user)
		if(istype(A))
			uses = spellbook.max_uses
			investing_time = 0
			has_sacrificed = 0
			user.spellremove()
			temp = "All spells and investments have been removed. You may now memorize a new set of spells."
		else
			to_chat(user, SPAN_WARNING("You must be in the wizard academy to re-memorize your spells."))
		. = TOPIC_REFRESH

	src.interact(user)
