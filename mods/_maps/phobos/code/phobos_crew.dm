#define WEBHOOK_SUBMAP_LOADED_PHOBOS	"webhook_submap_phobos"

/obj/submap_landmark/joinable_submap/phobos
	name = "Third Fleet Patrol Craft"
	archetype = /singleton/submap_archetype/phobos

/singleton/submap_archetype/phobos
	descriptor = "SCG Third Fleet Patrol Craft"
	map = "Third Fleet Patrol Craft"
	crew_jobs = list(
		/datum/job/submap/lieutenant,
		/datum/job/submap/pilot,
		/datum/job/submap/sergeant,
		/datum/job/submap/officer,
		/datum/job/submap/senior_doctor,
		/datum/job/submap/doctor,
		/datum/job/submap/engineer
	)
	call_webhook = WEBHOOK_SUBMAP_LOADED_PHOBOS

/obj/submap_landmark/spawnpoint/phobos
	name = "Commanding Officer"
	movable_flags = MOVABLE_FLAG_EFFECTMOVE

/obj/submap_landmark/spawnpoint/phobos/pilot
	name = "Army SCGSO Leader"

/obj/submap_landmark/spawnpoint/phobos/sergeant
	name = "Fleet Commander"

/obj/submap_landmark/spawnpoint/phobos/officer
	name = "Master at Arms"

/obj/submap_landmark/spawnpoint/phobos/senior_doctor
	name = "Physician"

/obj/submap_landmark/spawnpoint/phobos/doctor
	name = "Medical Technician"

/obj/submap_landmark/spawnpoint/phobos/engineer
	name = "Engineer"

/datum/job/submap/lieutenant
	title = "Commanding Officer"
	supervisors = "Third Fleet HQ, the Sol Central Government and the Sol Code of Uniform Justice"
	minimal_player_age = 14
	economic_power = 16
	minimum_character_age = list(SPECIES_HUMAN = 40)
	ideal_character_age = 50
	allowed_branches = list(/datum/mil_branch/fleet)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o3,
		/datum/mil_rank/fleet/o4
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_SCIENCE     = SKILL_TRAINED,
	                    SKILL_PILOT       = SKILL_TRAINED)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX,
	                    SKILL_SCIENCE     = SKILL_MAX)
	skill_points = 30

/datum/job/submap/pilot
	title = "Fleet Pilot"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commanding Officer and heads of staff"
	selection_color = "#2f2f7f"
	minimal_player_age = 0
	economic_power = 8
	minimum_character_age = list(SPECIES_HUMAN = 22)
	ideal_character_age = 24
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/command/bridgeofficer
	allowed_branches = list(
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/command/bridgeofficer/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o1
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_PILOT       = SKILL_TRAINED)

	max_skill = list(   SKILL_PILOT       = SKILL_MAX)
	skill_points = 20

/datum/job/submap/sergeant
	title = "Brig Chief"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Commanding Officer"
	economic_power = 5
	minimal_player_age = 7
	ideal_character_age = 35
	minimum_character_age = list(SPECIES_HUMAN = 27)
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/security/brig_chief
	allowed_branches = list(
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/security/brig_chief/fleet
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e6,
		/datum/mil_rank/fleet/e7,
		/datum/mil_rank/fleet/e8,
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_TRAINED,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_TRAINED,
	                    SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX,
	                    SKILL_FORENSICS   = SKILL_MAX)
	skill_points = 20

/datum/job/submap/officer
	title = "Master at Arms"
	total_positions = 3
	spawn_positions = 3
	supervisors = "Brig Chief"
	economic_power = 4
	minimal_player_age = 7
	minimum_character_age = list(SPECIES_HUMAN = 18)
	ideal_character_age = 25
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/security/maa
	allowed_branches = list(
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/security/maa/fleet,
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e3,
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_EVA         = SKILL_BASIC,
	                    SKILL_COMBAT      = SKILL_BASIC,
	                    SKILL_WEAPONS     = SKILL_TRAINED,
	                    SKILL_FORENSICS   = SKILL_BASIC)

	max_skill = list(   SKILL_COMBAT      = SKILL_MAX,
	                    SKILL_WEAPONS     = SKILL_MAX,
	                    SKILL_FORENSICS   = SKILL_EXPERIENCED)

	access = list()

/datum/job/submap/senior_doctor
	title = "Physician"
	department = "Medical"
	department_flag = MED
	minimal_player_age = 2
	minimum_character_age = list(SPECIES_HUMAN = 29)
	ideal_character_age = 45
	total_positions = 1
	spawn_positions = 1
	supervisors = "Commanding Officer"
	selection_color = "#013d3b"
	economic_power = 10
	alt_titles = list(
		"Surgeon")
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/medical/senior
	allowed_branches = list(
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/medical/senior/fleet,
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/o1,
		/datum/mil_rank/fleet/o2,
	)
	min_skill = list(   SKILL_BUREAUCRACY = SKILL_BASIC,
	                    SKILL_MEDICAL     = SKILL_EXPERIENCED,
	                    SKILL_ANATOMY     = SKILL_EXPERIENCED,
	                    SKILL_CHEMISTRY   = SKILL_BASIC,
						SKILL_DEVICES     = SKILL_TRAINED)

	max_skill = list(   SKILL_MEDICAL     = SKILL_MAX,
	                    SKILL_ANATOMY     = SKILL_MAX,
	                    SKILL_CHEMISTRY   = SKILL_MAX)
	skill_points = 20

	access = list()

/datum/job/submap/doctor
	title = "Medical Technician"
	total_positions = 1
	spawn_positions = 1
	supervisors = "physician and Commanding Officer"
	economic_power = 7
	minimum_character_age = list(SPECIES_HUMAN = 19)
	ideal_character_age = 40
	minimal_player_age = 0
	alt_titles = list("Corpsman")
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/medical/doctor
	allowed_branches = list(
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/medical/doctor/fleet,
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e3,
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5,
		/datum/mil_rank/fleet/e6,
	)
	min_skill = list(   SKILL_EVA     = SKILL_BASIC,
	                    SKILL_MEDICAL = SKILL_BASIC,
	                    SKILL_ANATOMY = SKILL_BASIC)

	max_skill = list(   SKILL_MEDICAL     = SKILL_MAX,
	                    SKILL_CHEMISTRY   = SKILL_MAX)

	access = list()
	skill_points = 22

/datum/job/submap/engineer
	title = "Engineer"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Commanding Officer"
	economic_power = 5
	minimal_player_age = 0
	minimum_character_age = list(SPECIES_HUMAN = 19)
	ideal_character_age = 30
	alt_titles = list(
		"Damage Control Technician",
		"Electrician",
		"Atmospheric Technician",
		)
	outfit_type = /singleton/hierarchy/outfit/job/torch/crew/engineering/engineer
	allowed_branches = list(
		/datum/mil_branch/fleet = /singleton/hierarchy/outfit/job/torch/crew/engineering/engineer/fleet,
	)
	allowed_ranks = list(
		/datum/mil_rank/fleet/e3,
		/datum/mil_rank/fleet/e4,
		/datum/mil_rank/fleet/e5,
	)
	min_skill = list(   SKILL_COMPUTER     = SKILL_BASIC,
	                    SKILL_EVA          = SKILL_BASIC,
	                    SKILL_CONSTRUCTION = SKILL_TRAINED,
	                    SKILL_ELECTRICAL   = SKILL_BASIC,
	                    SKILL_ATMOS        = SKILL_BASIC,
	                    SKILL_ENGINES      = SKILL_BASIC)

	max_skill = list(   SKILL_CONSTRUCTION = SKILL_MAX,
	                    SKILL_ELECTRICAL   = SKILL_MAX,
	                    SKILL_ATMOS        = SKILL_MAX,
	                    SKILL_ENGINES      = SKILL_MAX)
	skill_points = 20

/* ACCESS
 * =======
 */

var/global/const/access_away_phobos = "ACCESS_PHOBOS"
var/global/const/access_away_phobos_armory = "ACCESS_PHOBOS_ARMORY"
var/global/const/access_away_phobos_security = "ACCESS_PHOBOS_BRIG"
var/global/const/access_away_phobos_bridge = "ACCESS_PHOBOS_BRIDGE"
var/global/const/access_away_phobos_commander = "ACCESS_PHOBOS_COMMANDER"

/datum/access/access_away_phobos
	id = access_away_phobos
	desc = "Third Fleet Main"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_armory
	id = access_away_phobos_armory
	desc = "Third Fleet Armory"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_security
	id = access_away_phobos_security
	desc = "Third Fleet Brig"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_bridge
	id = access_away_phobos_bridge
	desc = "Third Fleet Bridge"
	region = ACCESS_REGION_NONE

/datum/access/access_away_phobos_commander
	id = access_away_phobos_commander
	desc = "Third Fleet Commander"
	region = ACCESS_REGION_NONE

// Patching-up //

/obj/item/clothing/under/solgov/utility/fleet/command/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/command/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/command/pilot/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/specialty/pilot,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/security/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/security/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/medical/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/medical/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/obj/item/clothing/under/solgov/utility/fleet/engineering/phobos
	accessories = list(
		/obj/item/clothing/accessory/solgov/department/engineering/fleet,
		/obj/item/clothing/accessory/solgov/fleet_patch/third
	)

/* OUTFITS
 * =======
 */

#define PATROL_OUTFIT_JOB_NAME(job_name) ("SCG Patrol Ship - Job - " + job_name)

/singleton/hierarchy/outfit/job/patrol
	hierarchy_type = /singleton/hierarchy/outfit/job/patrol
	uniform = /obj/item/clothing/under/solgov/utility/fleet
	shoes = /obj/item/clothing/shoes/dutyboots
	l_ear = /obj/item/device/radio/headset/away_scg_patrol
	l_pocket = /obj/item/device/radio
	r_pocket = /obj/item/crowbar/prybar
	id_types = list(/obj/item/card/id/phobos)
	id_slot = slot_wear_id
	pda_type = null
	belt = null
	backpack_contents = null
	flags = OUTFIT_EXTENDED_SURVIVAL
