/spell/cleave
	name = "Cleave"
	desc = "Клив вокруг."
	helptext = "We can instantly escape from most restraints and bindings, but we cannot do it often."
	enhancedtext = "More frequent escapes."
	ability_icon_state = "flesh_4"
	knowledgecost = 3
	verbpath = /mob/proc/heretic_cleave

//Escape Cuffs. By design this does not escape from straight jackets
/mob/proc/heretic_cleave()
	set category = "heretic"
	set name = "Escape Restraints (40)"
	set desc = "Removes handcuffs and legcuffs instantly."
