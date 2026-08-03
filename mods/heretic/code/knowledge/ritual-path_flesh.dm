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

/// Tier 2

// Трансмутации

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


/// Tier 4

// Возвышение - еретик превращается в мясного ИИ

/datum/power/heretic/ascend_flesh
	name = "Ascention: Path of Flesh"
	desc = "Возвышение мастера плоти."
