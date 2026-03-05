/*
Путь плоти - это путь, который создан для более "стабильного" отыгрыша. Он предлагает еретику ряд сейвящих способностей, которые при должной сноровке и знании базовых механик позволят ему уходить от погони и играть агрессивно.
В центре концепта пути лежит боди-хоррор и различные мутации живых организмов. Путь предлагает конврет членов экипажа в слуг еретика или создание конструкций из плоти
*/


/// Sacrifice

/// Tier 1

// Трансмутации

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


/// Tier 2

// Трансмутации

/datum/ritual/flesh/eyes
	name = "Eyes of Harbringer"
	desc = "Трансмутирует глаза, противоожоговый пакет и укрепленное стекло в фетиш, дарующий термальное зрение."
	icon = "necronimicon"
	result =
	components = list(
		/obj/item/organ/internal/eyes,
		/obj/item/storage/med_pouch/burn
	)
	tier = HERETIC_TIER_ONE





/datum/power/heretic/grasping_limbs
	name = "Transmutation: Grasping limbs"
	desc = "Трансмутирует две руки и мышеловку в капкан, игнорирующий еретика, но на долго останавливающий остальных."



/// Tier 3

// Трансмутации

/datum/power/heretic/metal_to_flesh
	name = "Transmutation: Metal into Flesh"
	desc = "Трансмутирует синтетика, ППТ, ИПС или Адхеранта в слугу, который способен быстро захватывать жертв."



/datum/power/heretic/node_of_flesh
	name = "Transmutation: Node of Flesh"
	desc = "Трансмутирует ДОБАВИТЬ в раскладываемый маяк, который лечит еретика и его созданий."



/// Tier 4

/datum/power/heretic/ascend_flesh
	name = "Ascention: Path of Flesh"
	desc = "Возвышение мастера плоти."
