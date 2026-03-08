var/global/list/heretic_powers = typesof(/datum/power/heretic) - /datum/power/heretic	//needed for the badmin verb for now
var/global/list/datum/power/heretic/powerinstances = list()

/datum/mind
	var/datum/heretic/heretic

/datum/heretic
	var/path = null

	var/list/known_rituals = list()
	var/list/sacrificed = list()
	var/list/purchased_powers = list()

	var/knowledgepoints = 15
	var/max_knowledgepoints = 15

	var/list/purchased_powers_history = list() //Used for round-end report, includes respec uses too.

/datum/heretic/New(gender=FEMALE)
	..()

/mob/proc/make_heretic()

	var/has_heart = FALSE

	if(!mind)				return
	if(!mind.heretic)	mind.heretic = new /datum/heretic(gender)

	verbs.Add(/datum/heretic/proc/ResearchTree)
	add_language(LANGUAGE_CULT)

	mind.heretic.known_rituals += /datum/ritual/book
	mind.heretic.known_rituals += /datum/ritual/sacrifice
	message_admins("Выдаём ритуалы.")

	if(!length(GLOB.powerinstances))
		for(var/P in heretic_powers)
			GLOB.powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/heretic/P in GLOB.powerinstances)
		if(!P.knowledgecost) // Is it free?
			if(!(P in mind.heretic.purchased_powers)) // Do we not have it already?
				mind.heretic.purchased_powers += P /// Add it.
				mind.heretic.purchasePower(mind, P, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/heretic/P in mind.heretic.purchased_powers)
		if(P.isVerb)
			if(!(P in src.verbs))
				verbs.Add(P.verbpath)
			if(P.make_hud_button)
				if(!src.ability_master)
					src.ability_master = new /obj/screen/movable/ability_master(null, src)
				src.ability_master.add_heretic_ability(
					object_given = src,
					verb_given = P.verbpath,
					name_given = P.name,
					ability_icon_given = P.ability_icon_state,
					arguments = list()
					)

	var/mob/living/carbon/human/H = src

	var/obj/item/organ/external/parent = H.get_organ(BP_CHEST)
	for(var/obj/item/organ/internal/I in parent.internal_organs)
		if(istype(I,/obj/item/organ/internal/heart))
			parent.internal_organs.Remove(I)

	for(var/obj/item/organ/internal/heart/livingheart/L in H.internal_organs)
		has_heart++
	if(has_heart == 0 && istype(src,/mob/living/carbon/human))
		var/obj/item/organ/external/chest = H.get_organ(BP_CHEST)
		var/obj/item/organ/internal/heart/livingheart/heart = new /obj/item/organ/internal/heart/livingheart
		heart.forceMove(src)
		heart.replaced(src, chest)
		heart = null

	return TRUE

//heretic Abilities
/obj/screen/ability/verb_based/heretic
	icon = 'mods/heretic/icons/heretic_powers.dmi'
	icon_state = "heretic_spell_base"
	background_base_state = "heretic"

//use this to force add powers
/obj/screen/movable/ability_master/proc/add_heretic_ability(object_given, verb_given, name_given, ability_icon_given, arguments)
	if(!object_given)
		message_admins("ERROR: add_heretic_ability() was not given an object in its arguments.")
	if(!verb_given)
		message_admins("ERROR: add_heretic_ability() was not given a verb/proc in its arguments.")
	if(get_ability_by_PROC_REF(verb_given))
		return // Duplicate
	var/obj/screen/ability/verb_based/heretic/A = new /obj/screen/ability/verb_based/heretic()
	A.ability_master = src
	A.object_used = object_given
	A.verb_to_call = verb_given
	A.ability_icon_state = ability_icon_given
	A.SetName(name_given)
	if(arguments)
		A.arguments_to_use = arguments
	ability_objects.Add(A)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen



/datum/power/heretic
	/// Cost for this power.
	var/knowledgecost = 500000
	/// _defines/gamemode.dm
	var/power_category = null

	var/tier = null

	var/path = null

// Modularheretic, totally stolen from the new player panel.  YAYY
/datum/heretic/proc/ResearchTree()//The new one
	set name = "-Research Tree-"
	set category = "Heretic"
	set desc = "Adapt yourself carefully."

	if(!usr || !usr.mind || !usr.mind.heretic)	return
	src = usr.mind.heretic

	if(!length(GLOB.powerinstances))
		for(var/P in powers)
			GLOB.powerinstances += new P()

	var/dat = "<html><head><title>Heretic Research Tree</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,name,desc,helptext,enhancedtext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+desc+"</b></font> <BR>"

					body += "<font size='2'><font color = 'orange'><b>"+helptext+"</b></font></font><BR>"

					if(enhancedtext)
					{
						body += "<font size='2'><font color = 'aquamarine'>Recursive Enhancement Effect: <b>"+enhancedtext+"</b></font></font><BR>"
					}

					if(!ownsthis)
					{
						body += "<a href='byond://?src=\ref[src];P="+power+"'>Research</a>"
					}

					body += "</td><td align='center'>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>heretic Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current evolution points left to Research with: [knowledgepoints]<br>
					Absorb other heretics to acquire more evolution points
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/i = 1
	for(var/datum/power/heretic/P in GLOB.powerinstances)
		var/ownsthis = 0

		if(P in purchased_powers)
			ownsthis = 1


		var/color = COLOR_DARKMODE_DARKBACKGROUND
		if(i%2 == 0)
			color = COLOR_DARKMODE_BACKGROUND


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P.enhancedtext]","[P]",[ownsthis])'
					>
					<span id='search[i]'><b>Research [P] - Cost: [ownsthis ? "Purchased" : P.knowledgecost]</b></span>
					</a>
					<br><span id='item[i]'></span>
				</td>
			</tr>

		"}

		i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	var/datum/browser/popup = new(usr, "powers", "Evolution Tree", 900, 480)
	popup.set_content(dat)
	popup.open()

/datum/heretic/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	if(href_list["P"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		purchasePower(M, href_list["P"])
		call(/datum/heretic/proc/ResearchTree)()



/datum/heretic/proc/purchasePower(datum/mind/M, Pname, remake_verbs = 1)
	if(!M || !M.heretic)
		return

	var/datum/power/heretic/Thepower = Pname


	for (var/datum/power/heretic/P in GLOB.powerinstances)
		if(P.name == Pname)
			Thepower = P
			break


	if(!Thepower)
		to_chat(M.current, "This is awkward.  heretic power purchase failed, please report this bug to a coder!")
		return

	if(Thepower in purchased_powers)
		return


	if(knowledgepoints < Thepower.knowledgecost)
		to_chat(M.current, "We cannot Research this... yet.  We must acquire more DNA.")
		return

	knowledgepoints -= Thepower.knowledgecost

	purchased_powers += Thepower

	if(Thepower.knowledgecost > 0)
		purchased_powers_history.Add("[Pname] ([Thepower.knowledgecost] points)")

	if(Thepower.make_hud_button && Thepower.isVerb)
		if(!M.current.ability_master)
			M.current.ability_master = new /obj/screen/movable/ability_master(null, M.current)
		M.current.ability_master.add_ling_ability(
			object_given = M.current,
			verb_given = Thepower.verbpath,
			name_given = Thepower.name,
			ability_icon_given = Thepower.ability_icon_state,
			arguments = list()
			)

	if(!Thepower.isVerb && Thepower.verbpath)
		call(M.current, Thepower.verbpath)()
	else if(remake_verbs)
		M.current.make_heretic()
