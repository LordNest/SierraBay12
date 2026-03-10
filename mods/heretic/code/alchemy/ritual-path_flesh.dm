/*
Путь плоти - это путь, который создан для более "стабильного" отыгрыша. Он предлагает еретику ряд сейвящих способностей, которые при должной сноровке и знании базовых механик позволят ему уходить от погони и играть агрессивно.
В центре концепта пути лежит боди-хоррор и различные мутации живых организмов. Путь предлагает конврет членов экипажа в слуг еретика или создание конструкций из плоти
*/


/// Sacrifice

/// Tier 1

// Трансмутации

/datum/ritual/flesh/blade
	name = "Maniac's Knife"
	desc = "Трансмутирует нож, скальпель и пакет крови в ритуальный кинжал."
	icon = "necronimicon"
	result = /obj/item/material/knife/heretic/flesh
	components = list(
		/obj/item/material/knife,
		/obj/item/scalpel/basic,
		/obj/item/reagent_containers/ivbag
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH

/datum/ritual/flesh/gloves
	name = "Stitcher Gloves"
	desc = "Трансмутирует латексные перчатки, сырое мясо и очиститель в не оставляющие отпечатков, но крайне подозрительные перчатки."
	icon = "necronimicon"
	result = /obj/item/clothing/gloves/forensic/stitcher
	components = list(
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/spray/cleaner
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH


/datum/ritual/flesh/fungus
	name = "Fungoid Flesh"
	desc = "Трансмутирует грибы и кровь в грибное сердце, что моментально разрастётся, перекрывая проход для всех, кроме еретика."
	icon = "necronimicon"
	result = /obj/item/grenade/spawnergrenade/blob
	components = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/decal/cleanable/blood,
		/obj/item/reagent_containers/spray/cleaner
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH


/datum/ritual/flesh/coat
	name = "Great Meatcoat"
	desc = "Трансмутирует плащ и мясо в предмет одежды, быстрее восстанавливающий выносливость и голод, пока надет."
	icon = "necronimicon"
	result = /obj/item/clothing/suit/greatcoat/meat
	components = list(
		/obj/item/clothing/accessory/cloak,
		/obj/item/reagent_containers/food/snacks/meat
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH

/// Tier 2

// Трансмутации

/datum/ritual/flesh/eyes
	name = "Eyes of Harbringer"
	desc = "Трансмутирует глаза, противоожоговый пакет и укрепленное стекло в фетиш, дарующий термальное зрение."
	icon = "necronimicon"
	result = /obj/item/clothing/glasses/thermal
	components = list(
		/obj/item/organ/internal/eyes,
		/obj/item/storage/med_pouch/burn
	)
	tier = HERETIC_TIER_TWO
	path = HERETIC_POWER_FLESH


/datum/ritual/flesh/linbs
	name = "Grasping limbs"
	desc = "Трансмутирует две руки и мышеловку в капкан, игнорирующий еретика, но надолго останавливающий остальных."
	icon = "necronimicon"
	result = /obj/item/beartrap/arms
	components = list(
		/obj/item/device/assembly/mousetrap,
		/obj/item/organ/external/arm,
		/obj/item/organ/external/arm/right
	)
	tier = HERETIC_TIER_TWO
	path = HERETIC_POWER_FLESH

/// Tier 3

// Трансмутации

/datum/ritual/flesh/metal_into_flesh
	name = "Metal into Flesh"
	desc = "Трансмутирует синтетика, ППТ, ИПС или Адхеранта в слугу, который способен быстро захватывать жертв."
	icon = "necronimicon"
	result = /mob/living/simple_animal/flesh_construct
	components = list()
	tier = HERETIC_TIER_THREE
	path = HERETIC_POWER_FLESH


/datum/ritual/flesh/node
	name = "Node of Flesh"
	desc = "Трансмутирует ДОБАВИТЬ в раскладываемый маяк, который лечит еретика и его созданий."
	icon = "necronimicon"
	result = /obj/item/supply_beacon
	components = list()
	tier = HERETIC_TIER_THREE
	path = HERETIC_POWER_FLESH



/// Tier 4

/datum/power/heretic/ascend_flesh
	name = "Ascention: Path of Flesh"
	desc = "Возвышение мастера плоти."
