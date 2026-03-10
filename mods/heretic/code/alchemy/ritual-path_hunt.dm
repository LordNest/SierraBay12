/*
A Hoonter must Hoont.
Путь Охоты предполагает контроль судна путём заражения членов экипажа вирусом, который прогрессирует одновременно с выполнением еретиком задач на Пути.
Вирус передаётся через кровь, а также при принесении в жертву человека.
Т1 Первоначальные симптомы включают положительные эффекты: ускорение регенерации, меньшая трата стамины
Т2 Добавляются: повышение силы (на 1 выше, чем у вида), улучшается восстановление стамины
Т3 Пациент ведёт себя агрессивно (спамит наррейтами, интент переключается на харм), для рас, которые питаются только растительной пищей пропадает запрет на белки,
T4 Когда всё готово к возвышению, у нас начинается локальный филиал ада. Все заражённые превращаются в монстров с задачей убить еретика
*/


/// Sacrifice

/// Tier 1

// Трансмутации

/datum/ritual/hunt/blade
	name = "Hunter's Saw"
	desc = "Трансмутирует нож, циркулярную пилу и доску в ритуальный кинжал."
	icon = "necronimicon"
	result = /obj/item/material/knife/heretic/hunt
	components = list(
		/obj/item/material/knife,
		/obj/item/circular_saw,
		/obj/item/stack/material/wood
	)
	tier = HERETIC_TIER_ONE

/datum/ritual/hunt/plague
	name = "Ravarkanian Plauge"
	desc = "Трансмутируйте пакет крови и ягоды, чтобы создать зараженную раварканской чумой кровь, которая при выпивании будет лечить вас."
	icon = "necronimicon"
	result = /obj/item/reagent_containers/ivbag/blood/plague
	components = list(
		/obj/item/reagent_containers/ivbag,
		/obj/item/reagent_containers/food/snacks/grown/harebell,
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/reagent_containers/food/snacks/grown/berry
	)
	tier = HERETIC_TIER_ONE


/datum/ritual/hunt/music_box
	name = "Music Box"
	desc = "Трансмутируйте диктофон, цветок мака и 5 кусков древесины, чтобы создать шкатулку, которая при использовании оглушает. Зараженные чумой оглушаются на большее время."
	icon = "necronimicon"
	result = /obj/item/bikehorn/music_box
	components = list(
		/obj/item/device/taperecorder,
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/stack/material/wood
	)
	tier = HERETIC_TIER_ONE


/datum/ritual/hunt/lanthern
	name = "Music Box"
	desc = "Трансмутируйте лампаду, цветок мака и банный веник, чтобы создать лампу на при использовании которой можно телепортироваться в сон и обратно. Две лампы нельзя ставить в одной и той же зоне и в космосе."
	icon = "necronimicon"
	result = /obj/item/supply_beacon
	components = list(
		/obj/item/device/flashlight/lantern,
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/mop/broom
	)
	tier = HERETIC_TIER_ONE


/// Tier 2

// Трансмутации

/datum/ritual/hunt/nanopaste
	name = "Eyes of the Hunter"
	desc = "Трансмутирует глаза, перевязочный пакет и укрепленное стекло в фетиш, дарующий отличное ночное зрение."



/datum/ritual/hunt/nanopaste
	name = "Hunterpaste"
	desc = "Трансмутирует нанопасту, колокльчик и пакет чумной крови в инструмент с помощью которого эффекты чумы могут примениться к силиковым помощникам на охоте."
	icon = "necronimicon"
	result = /obj/item/stack/nanopaste/cursed
	components = list(
		/obj/item/reagent_containers/ivbag/blood/plague,
		/obj/item/stack/nanopaste,
		/obj/item/reagent_containers/food/snacks/grown/harebell
	)
	tier = HERETIC_TIER_TWO


/// Tier 3

// Трансмутации

/datum/ritual/hunt/huntsman_garb
	name = "Transmutation: Huntsman Garb"
	desc = "Трансмутирует кожу, шлем, броню и мёртвое животное в комплект брони охотника, которая неплохо защищает от лазеров."
	icon = "necronimicon"
	result = /obj/item/storage/backpack/satchel/leather/hunter
	components = list(
		/obj/item/stack/material/leather,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/suit/armor/vest,
		/mob/living/simple_animal
	)
	tier = HERETIC_TIER_THREE


/datum/ritual/hunt/huntsman_garb
	name = "Transmutation: Astral Bell"
	desc = "Трансмутирует почки, колокольчик и пакет порченой крови в колокол, призывающий монстров, агрессивно настроенных ко всем вокруг."
	icon = "necronimicon"
	result = /obj/item/storage/backpack/satchel/leather/hunter
	components = list(
		/obj/item/organ/internal/kidneys,
		/obj/item/material/bell,
/obj/item/reagent_containers/ivbag/blood/plague
	)
	tier = HERETIC_TIER_THREE


/// Tier 4

/datum/power/heretic/ascend_hunt
	name = "Ascention: Path of Hunt"
	desc = "Возвышение охотника. Добавить описание."
