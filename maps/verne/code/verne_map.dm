#include "_verne_map.dm"
#include "verne_define.dm"

#include "verne_ranks.dm"
#include "verne_decals.dm"
#include "verne_lobby_music.dm"

/area/tdome/testing
	name = "Thunderdome (TESTING AREA)"
	icon_state = "purple"
	requires_power = 0
	dynamic_lighting = 0

/datum/map/build_away_sites()
	SSticker.start_ASAP = TRUE //Закоментируй, если не хочешь чтоб раунд моментально стартовал
	report_progress("РЕЖИМ РАЗРАБОТЧИКА, спавн авеек отключён.")
	return
