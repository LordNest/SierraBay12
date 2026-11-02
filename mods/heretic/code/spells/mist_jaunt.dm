/spell/targeted/ethereal_jaunt/mist_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	feedback = "MJ"
	school = "transmutation"
	charge_max = 30 SECONDS
	spell_flags = Z2NOCAST | NEEDSFOCUS | INCLUDEUSER
	invocation = "none"
	invocation_type = SpI_NONE
	range = 0
	max_targets = 1
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 4, Sp_POWER = 3)
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	duration = 5 SECONDS

	hud_state = "wiz_jaunt"
