/*
A Hoonter must Hoont.
Путь Охоты предполагает контроль судна путём заражения членов экипажа вирусом, который прогрессирует одновременно с выполнением еретиком задач на Пути.
Вирус передаётся через кровь, а также при принесении в жертву человека.
Т1 Первоначальные симптомы включают положительные эффекты: ускорение регенерации, меньшая трата стамины
Т2 Добавляются: повышение силы (на 1 выше, чем у вида), улучшается восстановление стамины
Т3 Пациент ведёт себя агрессивно (спамит наррейтами, интент переключается на харм), для рас, которые питаются только растительной пищей пропадает запрет на белки,
T4 Когда всё готово к возвышению, у нас начинается локальный филиал ада. Все заражённые превращаются в монстров с задачей убить еретика
*/

/// Blade

/// Sacrifice

/// Tier 1

// Трансмутации

/datum/power/heretic/plauge
	name = "Transmutation: Ravarkanian Plauge"
	desc = "Трансмутируйте пакет крови и ягоды, чтобы создать зараженную раварканской чумой кровь, которая при выпивании будет лечить вас."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/music_box
	name = "Transmutation: Music Box"
	desc = "Трансмутируйте диктофон, цветок мака и 5 кусков древесины, чтобы создать шкатулку, которая при использовании оглушает. Зараженные чумой оглушаются на большее время."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/lanthern
	name = "Transmutation: Mist Lanthern"
	desc = "Трансмутируйте диктофон, цветок мака и 5 кусков древесины, чтобы создать шкатулку, которая при использовании оглушает. Зараженные чумой оглушаются на большее время."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

// Заклинания

/datum/power/heretic/huntsman_whiste
	name = "Huntsman Whiste"
	desc = "Все лампы в зоне видимости с треском перегорают, а персональные источники света отключаются."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/huntsman_passion
	name = "Huntsman Passion"
	desc = "Ощутив прилив адреналина вы на время избавляетесь от всех эффектов замедляющих передвижение и даже боль, кажется, проходит."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/// Tier 2

// Трансмутации

/datum/power/heretic/huntsman_eyes
	name = "Transmutation: Eyes of the Hunter"
	desc = "Трансмутирует глаза, перевязочный пакет и укрепленное стекло в фетиш, дарующий отличное ночное зрение."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

/datum/power/heretic/hunterpaste
	name = "Transmutation: Hunterpaste"
	desc = "Трансмутирует нанопасту и пакет чумной крови в инструмент с помощью которого эффекты чумы могут примениться к силиковым помощникам на охоте."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/huntsman_garb
	name = "Transmutation: Huntsman Garb"
	desc = "Трансмутирует кожу, шлем, броню и мёртвое животное в комплект брони охотника, которая неплохо защищает от лазеров."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

// Заклинания

/datum/power/heretic/huntsman_instinct
	name = "Huntsman Instincts"
	desc = "Пассивная возможность слышать шаги за стенами, а также отсутствие ФОВ в броне и мехах."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/huntsman_return
	name = "Huntsman Return"
	desc = "Возвращает вас к последнему фонарю из которого вы перемещались в сон."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/// Tier 3

// Трансмутации

/datum/power/heretic/huntsman_eyes
	name = "Transmutation: Eyes of the Hunter"
	desc = "Трансмутирует глаза, перевязочный пакет и укрепленное стекло в фетиш, дарующий отличное ночное зрение."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

// Заклинания

/// Tier 4
