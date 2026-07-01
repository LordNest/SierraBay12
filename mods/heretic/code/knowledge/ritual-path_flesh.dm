/*
Путь плоти - это путь, который создан для более "стабильного" отыгрыша. Он предлагает еретику ряд сейвящих способностей, которые при должной сноровке и знании базовых механик позволят ему уходить от погони и играть агрессивно.
В центре концепта пути лежит боди-хоррор и различные мутации живых организмов. Путь предлагает конврет членов экипажа в слуг еретика или создание конструкций из плоти
*/


/// Sacrifice

// Жертвы получают органы, которые заставляют их хотеть есть мясо и они получают урон от битья еретика. Чем дальше в лес, тем больше изменений

/// Tier 1

// Трансмутации

/datum/heretic_knowledge/flesh/gloves
	name = "Stitcher Gloves"
	desc = "Трансмутирует латексные перчатки, сырое мясо и очиститель в не оставляющие отпечатков, но крайне подозрительные перчатки."
	icon = "necronimicon"
	result_atoms = list(/obj/item/clothing/gloves/forensic/stitcher)
	required_atoms = list(
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/spray/cleaner
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH


/datum/heretic_knowledge/flesh/fungus
	name = "Fungoid Flesh"
	desc = "Трансмутирует грибы и кровь в грибное сердце, что моментально разрастётся, перекрывая проход для всех, кроме еретика."
	icon = "necronimicon"
	result_atoms = list(/obj/item/grenade/spawnergrenade/blob)
	required_atoms = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/decal/cleanable/blood,
		/obj/item/reagent_containers/spray/cleaner
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH


/datum/heretic_knowledge/flesh/coat
	name = "Great Meatcoat"
	desc = "Трансмутирует плащ и мясо в предмет одежды, быстрее восстанавливающий выносливость и голод, пока надет."
	icon = "necronimicon"
	result_atoms = list(/obj/item/clothing/suit/greatcoat/meat)
	required_atoms = list(
		/obj/item/clothing/accessory/cloak,
		/obj/item/reagent_containers/food/snacks/meat
	)
	tier = HERETIC_TIER_ONE
	path = HERETIC_POWER_FLESH

/// Tier 2

// Трансмутации

/datum/heretic_knowledge/flesh/eyes
	name = "Eyes of Harbringer"
	desc = "Трансмутирует глаза, противоожоговый пакет и укрепленное стекло в фетиш, дарующий термальное зрение."
	icon = "necronimicon"
	result_atoms = list(/obj/item/clothing/glasses/thermal)
	required_atoms = list(
		/obj/item/organ/internal/eyes,
		/obj/item/storage/med_pouch/burn
	)
	tier = HERETIC_TIER_TWO
	path = HERETIC_POWER_FLESH


/datum/heretic_knowledge/flesh/linbs
	name = "Grasping limbs"
	desc = "Трансмутирует две руки и мышеловку в капкан, игнорирующий еретика, но надолго останавливающий остальных."
	icon = "necronimicon"
	result_atoms = list(/obj/item/beartrap/arms)
	required_atoms = list(
		/obj/item/device/assembly/mousetrap,
		/obj/item/organ/external/arm,
		/obj/item/organ/external/arm //right
	)
	tier = HERETIC_TIER_TWO
	path = HERETIC_POWER_FLESH

/// Tier 3

// Трансмутации

/datum/heretic_knowledge/flesh/metal_into_flesh
	name = "Metal into Flesh"
	desc = "Трансмутирует синтетика, ППТ, ИПС или Адхеранта в слугу, который способен быстро захватывать жертв."
	icon = "necronimicon"
	result_atoms = list(/mob/living/simple_animal/flesh_construct)
	required_atoms = list()
	tier = HERETIC_TIER_THREE
	path = HERETIC_POWER_FLESH


/datum/heretic_knowledge/flesh/node
	name = "Node of Flesh"
	desc = "Трансмутирует ДОБАВИТЬ в раскладываемый маяк, который лечит еретика и его созданий."
	icon = "necronimicon"
	result_atoms = list(/obj/item/supply_beacon)
	required_atoms = list()
	tier = HERETIC_TIER_THREE
	path = HERETIC_POWER_FLESH



/// Tier 4

// Возвышение - еретик превращается в мясного ИИ

/datum/power/heretic/ascend_flesh
	name = "Ascention: Path of Flesh"
	desc = "Возвышение мастера плоти."
