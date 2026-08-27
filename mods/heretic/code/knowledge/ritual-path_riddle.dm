/*
Путь загадки направлен больше на флафф и различные ситуативные способности. Еретик этого пути способен на прямое боестолкновение, однако не на начальных этапах.
Мы используем часть вещей из похождений Алисы (больше к её тёмной версии), часть из Сна в Летнюю ночь и просто культурные отсылки к различным загадкам
*/




/// Sacrifice

/// Tier 1

// Трансмутации

/datum/heretic_knowledge/riddle/blade
	name = "Vorpal Blade"
	desc = "Трансмутирует нож, ботанический топор и колоду карт в ритуальный кинжал."
	icon = "necronimicon"
	result_atoms = list(/obj/item/material/knife/heretic/riddle)
	required_atoms = list(
		/obj/item/material/knife,
		/obj/item/material/hatchet,
		/obj/item/stack/material/wood
	)
	tier = HERETIC_TIER_ONE

/datum/heretic_knowledge/riddle/shroom_cap
	name = "Transmutation: Shroom Cap"
	desc = "Трансмутирует добавить список в грибную шляпку, которая позволяет уменьшаться в размерах и пролезать через систему вентиляции."




/datum/heretic_knowledge/riddle/code_of_confusion
	name = "Transmutation: Code of Confusion"
	desc = "Трансмутирует добавить список в лист, на котором написан код от аплинка. Аплинк выдаётся аналогично аплинку ниндзи без телекристаллов"

/datum/heretic_knowledge/riddle/keys


/// Tier 2

// Трансмутации

/datum/heretic_knowledge/riddle/riddle_of_blood
	name = "Transmutation: Riddle of Blood"
	desc = "Трансмутирует добавить и кровь человека в зелье, выпив которое человек станет копией того, чья кровь была использована (вылита на пол)."



/datum/heretic_knowledge/riddle/riddle_of_steel
	name = "Transmutation: Riddle of Steel"
	desc = "Трансмутирует большое количество металлов и крови, чтобы разгадать загадку стали и изготовить тяжёлый доспех, отлично защищающий от пуль и ближнего боя"



/// Tier 3

// Трансмутации

/datum/heretic_knowledge/riddle/pocket_watch
	name = "Transmutation: Pocket Watch"
	desc = "Трансмутирует добавить в карманные часы, отматывающие время, позицию и состояние тела до момента, когда были использованы. При использовании дольше минуты - принудительно возвращают. Перезарядка 10 минут."



/datum/heretic_knowledge/riddle/riddle_of_passion
	name = "Transmutation: Riddle of Passion"
	desc = "Трансмутирует добавить цветы в эликсир, которым необходмио прокапать глаза спящего, который влюбится в первого, кого увидит после пробуждения."




/// Tier 4

/datum/heretic_knowledge/riddle/ascend_riddle
	name = "Ascention: Path of Riddle"
	desc = "Возвышение Алисы. Добавить описание."
