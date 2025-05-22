/*
Путь плоти - это путь, который создан для более "стабильного" отыгрыша. Он предлагает еретику ряд сейвящих способностей, которые при должной сноровке и знании базовых механик позволят ему уходить от погони и играть агрессивно.
В центре концепта пути лежит боди-хоррор и различные мутации живых организмов. Путь предлагает конврет членов экипажа в слуг еретика или создание конструкций из плоти
*/

/// Blade

/// Sacrifice

/// Tier 1

// Трансмутации

/datum/power/heretic/stitcher_gloves
	name = "Transmutation: Stitcher Gloves"
	desc = "Трансмутирует латексные перчатки, сырое мясо и очиститель в не оставляющие отпечатков, но крайне подозрительные перчатки."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/fungoid_flesh
	name = "Transmutation: Fungoid Flesh"
	desc = "Трансмутирует грибы и кровь в грибное сердце, что моментально разрастётся, перекрывая проход для всех, кроме еретика."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/meatcoat
	name = "Transmutation: Great Meatcoat"
	desc = "Трансмутирует плащ и мясо в предмет одежды, быстрее восстанавливающий выносливость и голод, пока надет."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

// Заклинания

/datum/power/heretic/flesh_mend
	name = "Flesh Mend"
	desc = "Ценой голода лечит урон, нанесённый владельцу. Может использоваться даже в бессознательном состоянии."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/datum/power/heretic/sensory_overload
	name = "Sensory Overload"
	desc = "Воздействие на ЦНС или её подобие заставляет жертву испытывать жуткую агонию, после того, как вы её коснетесь"
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/// Tier 2

// Трансмутации

/datum/power/heretic/harbringer_eyes
	name = "Transmutation: Eyes of Harbringer"
	desc = "Трансмутирует глаза, противоожоговый пакет и укрепленное стекло в фетиш, дарующий термальное зрение."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

datum/power/heretic/grasping_limbs
	name = "Transmutation: Grasping limbs"
	desc = "Трансмутирует две руки и мышеловку в капкан, игнорирующий еретика, но на долго останавливающий остальных."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

datum/power/heretic/chameleon_cloack
	name = "Transmutation: Grasping limbs"
	desc = "Трансмутирует две руки и мышеловку в капкан, игнорирующий еретика, но на долго останавливающий остальных."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

// Заклинания

/datum/power/heretic/create_ghoul
	name = "Create Ghoul"
	desc = "Призывает дединсайда, который делает других дедаутсайдами. Извините. Переписать."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

/datum/power/heretic/blood_siphon
	name = "Blood Siphon"
	desc = "вытягивает в АоЕ кровь, лечит раны, собирает кровь с пола (привет культ, как вы там?)."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/// Tier 3

// Трансмутации

/datum/power/heretic/metal_to_flesh
	name = "Transmutation: Metal into Flesh"
	desc = "Трансмутирует синтетика, ППТ, ИПС или Адхеранта в слугу, который способен быстро захватывать жертв."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

/datum/power/heretic/node_of_flesh
	name = "Transmutation: Node of Flesh"
	desc = "Трансмутирует ДОБАВИТЬ в раскладываемый маяк, который лечит еретика и его созданий."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle

// Заклинания

/datum/power/heretic/cleave
	name = "Cleave"
	desc = "Рвём наручники, смирительные рубашки, микростаним всех вокруг на 1 секунду."
	knowledgecost = 1
	verbpath = /mob/proc/create_circle

/// Tier 4

/datum/power/heretic/ascend_flesh
	name = "Ascention: Path of Flesh"
	desc = "Трансмутирует ДОБАВИТЬ в раскладываемый маяк, который лечит еретика и его созданий."
	knowledgecost = 2
	verbpath = /mob/proc/create_circle
