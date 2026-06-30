#define HERETIC_POWER_GENERAL        "General"     // Общие силы, призыв книги, круг и т.п.
#define HERETIC_POWER_FLESH    "Path of Flesh"     // Путь плоти, биопанк, счастье, бодихоррор
#define HERETIC_POWER_HUNT "Path of Moonhunter"    // Бладборн референс, играем от вирусов
#define HERETIC_POWER_RIDDLE  "Path of Riddle"     // Алиса в стране чудес, красная королева
#define HERETIC_POWER_COSMOS "Path of Cosmos"      // Лавкрафт референс, солянка из ТГшного еретика

#define HERETIC_POWER_SIDE_FH    "Side Path - Flesh and Hunt"
#define HERETIC_POWER_SIDE_HR   "Side Path - Hunt and Riddle"
#define HERETIC_POWER_SIDE_RC "Side Path - Riddle and Cosmos"
#define HERETIC_POWER_SIDE_FC  "Side Path - Cosmos and Flesh"

#define HERETIC_TIER_ONE   1
#define HERETIC_TIER_TWO   2
#define HERETIC_TIER_THREE 3
#define HERETIC_TIER_FOUR  4

#define SACRIFICE_COMMON   1
#define SACRIFICE_AWAY     2
#define SACRIFICE_PSIONIC  3
#define SACRIFICE_COMMAND  3


// sound\ambience\meat_monster_arrival.ogg

/// Defines are used in /proc/has_living_heart() to report if the heretic has no heart period, no living heart, or has a living heart.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

#define HERETIC_DRAFT_TIER_MAX 5

/// The default drain speed for heretic rift's, anything below this will be considered a fast drain, and be very noticeable and cause a overlay
#define HERETIC_RIFT_DEFAULT_DRAIN_SPEED 10 SECONDS

/// Sources of knowledge purchased for heretics, used for positioning in the UI
#define HERETIC_KNOWLEDGE_TREE "tree"
#define HERETIC_KNOWLEDGE_SHOP "shop"
#define HERETIC_KNOWLEDGE_DRAFT "draft"
#define HERETIC_KNOWLEDGE_START "start"

///from base of atom/movable/on_changed_z_level(): (turf/old_turf, turf/new_turf, same_z_layer)
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"

///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"

// Heretic path defines.
#define PATH_START "Start Path"
#define PATH_SIDE "Side Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"
#define PATH_COSMIC "Cosmic Path"
#define PATH_LOCK "Lock Path"
#define PATH_MOON "Moon Path"

//Heretic knowledge tree defines
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_PURCHASED_DEPTH "purchased_depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"
#define HKT_COST "cost"
#define HKT_CATEGORY "category"
/// Only present for already researched knowledge.
#define HKT_INSTANCE "instance"
/// unique identifier most commonly used for identifying what knowledge is researchable
#define HKT_ID "id"

#define BGR_SIDE "node_side"

/// defines for the depths of the heretic knowledge tree nodes
#define HKT_DEPTH_START 2
#define HKT_DEPTH_TIER_1 3
#define HKT_DEPTH_DRAFT_1 4
#define HKT_DEPTH_TIER_2 5
#define HKT_DEPTH_DRAFT_2 6
#define HKT_DEPTH_ROBES 7
#define HKT_DEPTH_TIER_3 8
#define HKT_DEPTH_DRAFT_3 9
#define HKT_DEPTH_ARMOR 10
#define HKT_DEPTH_TIER_4 11
#define HKT_DEPTH_DRAFT_4 12
#define HKT_DEPTH_ASCENSION 13

#define HERETIC_CAN_ASCEND "can_ascend"

/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100


/// Heretic signals

/// From /datum/action/cooldown/spell/touch/mansus_grasp/cast_on_hand_hit : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK "mansus_grasp_attack"
	/// Default behavior is to use the hand, so return this to blocks the mansus fist from being consumed after use.
	#define COMPONENT_BLOCK_HAND_USE (1<<0)
/// From /datum/action/cooldown/spell/touch/mansus_grasp/cast_on_secondary_hand_hit : (mob/living/source, atom/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY "mansus_grasp_attack_secondary"
	/// Default behavior is to continue attack chain and do nothing else, so return this to use up the hand after use.
	#define COMPONENT_USE_HAND (1<<0)

/// From /obj/item/melee/sickly_blade/afterattack : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_BLADE_ATTACK "blade_attack"
/// From /obj/item/melee/sickly_blade/ranged_interact_with_atom (without proximity) : (mob/living/source, mob/living/target)
#define COMSIG_HERETIC_RANGED_BLADE_ATTACK "ranged_blade_attack"

/// For [/datum/status_effect/protective_blades] to signal when it is triggered
#define COMSIG_BLADE_BARRIER_TRIGGERED "blade_barrier_triggered"

/// at the end of determine_drafted_knowledge
#define COMSIG_HERETIC_SHOP_SETUP "heretic_shop_finished"

/// called on the antagonist datum, upgrades the passive to level 2
#define COMSIG_HERETIC_PASSIVE_UPGRADE_FIRST "heretic_passive_upgrade_first"
/// called on the antagonist datum, upgrades the passive to level 3
#define COMSIG_HERETIC_PASSIVE_UPGRADE_FINAL "heretic_passive_upgrade_final"
