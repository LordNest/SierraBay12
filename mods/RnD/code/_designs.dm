/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a  to denote that they aren't reagents.
The currently supporting non-reagent materials:

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 2000 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).

*/
//Note: More then one of these can be added to a design.
/datum/design						//Datum for object designs, used in construction
	var/name = null 				//Name of the created object. If null it will be 'guessed' from build_path if possible.
	var/desc = null					//Description of the created object. If null it will use group_desc and name where applicable.
	var/item_name = null			//An item name before it is modified by various name-modifying procs
	var/name_category		//If set, name is modified into "[name_category] ([item_name])"
	var/id = "id"					//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols.
	var/list/req_tech = list()		//IDs of that techs the object originated from and the minimum level requirements.
	var/build_type = null			//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()		//List of materials. Format: "id" = amount.
	var/list/chemicals = list()		//List of chemicals.
	var/build_path = null			//The path of the object that gets created.
	var/time = 10					//How many ticks it requires to build
	var/list/category = null        //Primarily used for Mech Fabricators, but can be used for anything
	var/sort_string = "ZZZZZ"		//Sorting order
	var/starts_unlocked = FALSE     //If true does not require any technologies and unlocked from the start
	var/shortname = null			// Used for naming in RDconsole
	var/datum/computer_file/binary/design/file
	var/adjust_materials = TRUE		//Whether material efficiency applies to this design
	var/list/ui_data = new 			// Additional data for UI use
	var/list/autolathe_category = list()	//Categories for the autolathe design download software
	var/list/access = list()		//List of access groups that can use this design


/datum/design/New()
	..()
	AssembleDesignInfo()
	item_name = name

//These procs are used in subtypes for assigning names and descriptions dynamically
/datum/design/proc/AssembleDesignInfo()
	AssembleDesignName()
	AssembleDesignDesc()
	AssembleDesignId()
	AssembleDesignUIData()


	return

/datum/design/proc/AssembleDesignName()
	if(!name && build_path)					//Get name from build path if posible
		var/atom/movable/A = build_path
		name = initial(A.name)
		item_name = name
	if(!shortname)
		shortname = capitalize(name)
	return

/datum/design/proc/AssembleDesignDesc()
	if(desc)
		return
	if(!desc)								//Try to make up a nice description if we don't have one
		desc = "Allows for the construction of \a [item_name]."
		return

/datum/design/proc/AssembleFileDesignInfo(atom/temp_atom)
	AssembleDesignName()
	AssembleDesignDesc()
	AssembleDesignId()

/datum/design/proc/AssembleDesignId()
	if(id)
		return
	id = type

/datum/design/proc/AssembleDesignUIData()
	ui_data = list(
		"id" = "[id]", "name" = name, "desc" = desc, "time" = time,
		"category" = category, "adjust_materials" = adjust_materials
	)

	if(length(materials))
		var/list/RS = list()

		for(var/material in materials)
			var/material/material_datum = SSmaterials.get_material_by_name(material)
			RS.Add(list(list("id" = material, "name" = material_datum.display_name, "req" = materials[material])))

		ui_data["materials"] = RS

	if(length(chemicals))
		var/list/RS = list()

		for(var/reagent in chemicals)
			CallReagentName(reagent)
			RS.Add(list(list("id" = reagent, "name" = CallReagentName(reagent), "req" = chemicals[reagent])))

		ui_data["chemicals"] = RS

/datum/design/proc/CallReagentName(reagent_type)
	var/datum/reagent/R = reagent_type
	return ispath(reagent_type, /datum/reagent) ? initial(R.name) : "Unknown"

/datum/design/ui_data()
	RETURN_TYPE(/list)
	return ui_data
//Returns a new instance of the item for this design
//This is to allow additional initialization to be performed, including possibly additional contructor arguments.
/datum/design/proc/Fabricate(newloc, mat_efficiency, fabricator)

	var/atom/A = new build_path(newloc)

	if(mat_efficiency != 1 && adjust_materials)
		for(var/obj/O in A.GetAllContents(includeSelf = TRUE))
			if(length(O.matter))
				for(var/i in O.matter)
					O.matter[i] = round(O.matter[i] * mat_efficiency, 0.01)


	return A

/datum/design/item
	build_type = PROTOLATHE

// Testing helper
GLOBAL_LIST_INIT(build_path_to_design_datum_path, populate_design_datum_index())

/proc/populate_design_datum_index()
	RETURN_TYPE(/list)
	. = list()
	for(var/path in typesof(/datum/design))
		var/datum/design/fake_design = path
		if(initial(fake_design.build_path))
			.[initial(fake_design.build_path)] = path

/datum/design/autolathe/
	build_type = PROTOLATHE			// From now on autolathe capable printing protolathe designs

/datum/design/autolathe/New()
	. = ..()
	if(!build_path)
		return
	var/obj/item/A = new src.build_path
	materials = A.matter
	desc = A.desc

/datum/design/proc/autolathe_list_category()
	for(var/datum/design/autolathe/P in subtypesof(/datum/design/autolathe))
		if(P.category in autolathe_category)
			continue
		else
			autolathe_category += P.category
	return autolathe_category
