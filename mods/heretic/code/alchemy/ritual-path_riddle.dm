/*
Путь загадки направлен больше на флафф и различные ситуативные способности. Еретик этого пути способен на прямое боестолкновение, однако не на начальных этапах.
Мы используем часть вещей из похождений Алисы (больше к её тёмной версии), часть из Сна в Летнюю ночь и просто культурные отсылки к различным загадкам
*/


/// Blade

/obj/item/material/knife/heretic/riddle
	name = "vorpal blade"

/// Sacrifice

/// Tier 1

// Трансмутации

/datum/power/heretic/shroom_cap
	name = "Transmutation: Shroom Cap"
	desc = "Трансмутирует добавить список в грибную шляпку, которая позволяет уменьшаться в размерах и пролезать через систему вентиляции."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle


/datum/power/heretic/code_of_confusion
	name = "Transmutation: Code of Confusion"
	desc = "Трансмутирует добавить список в лист, на котором написан код от аплинка. Аплинк выдаётся аналогично аплинку ниндзи без телекристаллов"
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/*
/datum/power/heretic/blue_elixir
	name = "Transmutation: Blue Elixir"
	desc = "Трансмутирует добавить список в эликсир, который при выпивании позволяет сливаться с окружащим миром, делая вас полупрозрачным на короткий промежуток времени."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle
*/


/// Tier 2

// Трансмутации

/datum/power/heretic/riddle_of_blood
	name = "Transmutation: Riddle of Blood"
	desc = "Трансмутирует добавить и кровь человека в зелье, выпив которое человек станет копией того, чья кровь была использована (вылита на пол)."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

/datum/power/heretic/riddle_of_steel
	name = "Transmutation: Riddle of Steel"
	desc = "Трансмутирует большое количество металлов и крови, чтобы разгадать загадку стали и изготовить тяжёлый доспех, отлично защищающий от пуль и ближнего боя"
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/// Tier 3

// Трансмутации

/datum/power/heretic/pocket_watch
	name = "Transmutation: Pocket Watch"
	desc = "Трансмутирует добавить в карманные часы, отматывающие время, позицию и состояние тела до момента, когда были использованы. При использовании дольше минуты - принудительно возвращают. Перезарядка 10 минут."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/riddle_of_passion
	name = "Transmutation: Riddle of Passion"
	desc = "Трансмутирует добавить цветы в эликсир, которым необходмио прокапать глаза спящего, который влюбится в первого, кого увидит после пробуждения."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle


/// Tier 4

/datum/power/heretic/ascend_riddle
	name = "Ascention: Path of Riddle"
	desc = "Возвышение Алисы. Добавить описание."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle
