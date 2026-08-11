#ifndef MODPACK_HERETIC
#define MODPACK_HERETIC

#include "_heretic.dm"

#include "code/_defines.dm"
#include "code/_heretic_paths.dm"

#include "code/_status_effect.dm"

#include "code/antagonist.dm"
#include "code/helpers.dm"
#include "code/heretic_knowledge.dm"

#include "code/knowledge/alchemy.dm"
	#include "code/knowledge/flesh_lore.dm"
	#include "code/knowledge/hunter_lore.dm"
	#include "code/knowledge/heretic_paths.dm"
	#include "code/knowledge/heretic_armor_knowledge.dm"
	#include "code/knowledge/ritual-path_hunt.dm"
	#include "code/knowledge/ritual-path_riddle.dm"
	#include "code/knowledge/ritual-sidepaths.dm"
	#include "code/knowledge/sacrifice.dm"
	#include "code/knowledge/starting_lore.dm"
	#include "code/knowledge/tier_four.dm"
	#include "code/knowledge/tier_one.dm"
	#include "code/knowledge/tier_three.dm"
	#include "code/knowledge/tier_two.dm"

	#include "code/items/general.dm"
	#include "code/items/items-path_flesh.dm"
	#include "code/items/items-path_hunt.dm"
	#include "code/items/items-path_riddle.dm"

	#include "code/spells/crimson_cleave.dm"
	#include "code/spells/flesh_surgery.dm"
	#include "code/spells/mist_jaunt.dm"
	#include "code/spells/shadow_cloak.dm"
	// Tier 2
	#include "code/spells/wave_of_desperation.dm"

	#include "code/spells/spells-hunt.dm"
	#include "code/spells/spells-riddle.dm"
	#include "code/spells/spells-side-cf.dm"
	#include "code/spells/spells-side-fh.dm"

	#include "code/turfs/heretic_turfs.dm"

#include "code/mobs/heretic_summons.dm"
	#include "code/mobs/maid_in_the_mirror.dm"
	#include "code/mobs/path_flesh.dm"

#include "code/powers.dm"


#endif
