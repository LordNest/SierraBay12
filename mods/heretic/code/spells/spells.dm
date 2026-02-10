// Отсюда наш антаг диктует свою волю галактическому сообществу.
// Может реворкнем?
// Обязательно реворкнем. И не раз. Но потом.

/obj/screen/ability/spell/heretic
	icon = 'mods/heretic/icons/heretic_powers.dmi'
	icon_state = "grey_spell_base"
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
				name = "Artefact: [capitalize(initial(O.name))]" //because 99.99% of objects don't have capitals in them and it makes it look weird.
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
		if(spellbook.book_flags & INVESTABLE)
			if(investing_time)
				dat += "<center><b>Currently investing in a slot...</b></center>"
			else
				dat += "<center><a href='byond://?src=\ref[src];invest=1'>Invest a Spell Slot</a><br><i>Investing a spellpoint will return two spellpoints back in 15 minutes.<br>Some say a sacrifice could even shorten the time...</i></center>"
		if(!(spellbook.book_flags & NOREVERT))
			dat += "<center><a href='byond://?src=\ref[src];book=1'>Choose different spellbook.</a></center>"
		if(!(spellbook.book_flags & NO_LOCKING))
			dat += "<center><a href='byond://?src=\ref[src];lock=1'>[spellbook.book_flags & LOCKED ? "Unlock" : "Lock"] the spellbook.</a></center>"
	show_browser(user, dat,"window=spellbook")
