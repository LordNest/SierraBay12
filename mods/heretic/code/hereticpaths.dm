/*
Браузер аналогично браузеру генокрада
*/

/client
	var/datum/managed_browser/hereticpaths/hereticpaths = null

/datum/managed_browser/hereticpaths
	base_browser_id = "heretic_paths"
	title = "Heretic Paths"
	size_x = 480
	size_y = 600
	var/textbody = null

/datum/managed_browser/hereticpaths/New(client/new_client)
	if(!new_client.mob || !new_client.mob.mind || !new_client.mob.mind.heretic)
		message_admins("[new_client] tried to access heretic evolutions while not heretic.")
		qdel(src)

	..()

/datum/managed_browser/hereticpaths/Destroy()
	if(my_client)
		my_client.hereticpaths = null
	return ..()

/datum/managed_browser/hereticpaths/get_html()
	var/list/dat = list("<html><body>")
	var/knowledgepoints_current = my_client.mob.mind.heretic.knowledgepoints
	var/knowledgepoints_max = my_client.mob.mind.heretic.max_knowledgepoints

	dat += "<center>Genetic Points Available: [knowledgepoints_current] / [knowledgepoints_max] <br>"
	dat += "Obtain more by feeding on your own kind. <br> <hr>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];tutorial=1'>What am I?</a><br><hr>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];inherent=1'>Inherent</a>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];armor=1'>Armor</a>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];weapons=1'>Weapons</a>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];stings=1'>Stings</a>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];shrieks=1'>Shrieks</a>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];health=1'>Health</a>"
	dat += "<a style='background-color:#c72121;' href='?src=\ref[src];enhancements=1'>Enhancements</a></center>"
	if(textbody)
		dat += "<table border='1' style='width:100%; background-color:#000000;'>"
		dat += "[textbody]"
		dat += "</table>"
	dat += "</body></html>"

	return dat.Join()

/datum/managed_browser/hereticpaths/Topic(href, href_list[])
	if(!my_client)
		return FALSE

	if(href_list["close"])
		return

	if(href_list["inherent"])
		generate_abilitylist(CHANGELING_POWER_INHERENT)

	if(href_list["armor"])
		generate_abilitylist(CHANGELING_POWER_ARMOR)

	if(href_list["weapons"])
		generate_abilitylist(CHANGELING_POWER_WEAPONS)

	if(href_list["stings"])
		generate_abilitylist(CHANGELING_POWER_STINGS)

	if(href_list["shrieks"])
		generate_abilitylist(CHANGELING_POWER_SHRIEKS)

	if(href_list["health"])
		generate_abilitylist(CHANGELING_POWER_HEALTH)

	if(href_list["enhancements"])
		generate_abilitylist(CHANGELING_POWER_ENHANCEMENTS)

	if(href_list["evolve"])
		var/datum/mind/M = my_client.mob.mind
		var/datum/heretic/C = my_client.mob.mind.heretic
		var/datum/power/heretic/Thepower = href_list["evolve"]

		for (var/datum/power/heretic/P in GLOB.powerinstances)
			if(P.name == Thepower)
				Thepower = P
				break

		if(!istype(M))
			return

		if(!Thepower)
			CRASH("Purchase failed. Inform a dev of this error.")

		if(Thepower in C.purchased_powers)
			to_chat(M.current, "You already have this ability! Inform a dev of this error.") /// Should not be possible
			return

		if(C.knowledgepoints < Thepower.knowledgecost)
			to_chat(M.current, "We cannot evolve this... yet.  We must acquire more DNA.")
			return

		C.purchased_powers += Thepower /// Set it to purchased
		C.knowledgepoints -= Thepower.knowledgecost
		generate_abilitylist(Thepower.power_category) /// Refresh the UI

		my_client.mob.mind.heretic.purchasePower(M, Thepower)

	if(href_list["tutorial"])
		textbody = "<tr><th><font color='#c72121'><center>What am I?</center></font><br></th></tr>"
		textbody += "<tr><td>"
		textbody += "<font color='#F7F7ED'>You are a heretic, a creature empowered with genetic-based abilities that change your body in bizarre ways."
		textbody += " It's probably best the crew doesn't know about your power -- at least not right away.</font><br><br>"
		textbody += "<font color='#F7F7ED'>What a heretic <i>is</i>, however, is up to you. Are you a strange alien impersonating crew? Are you a"
		textbody += " normal crewmember infected with a parasite? An experiment gone wrong? It's up to you to make the story.</font><br><br>"
		textbody += "<font color='#F7F7ED'>Of course, you need to know how it works to begin with.</font><br><br>"
		textbody += "<font color='#F7F7ED'>Your abilities cost chemicals that your body will slowly regenerate with varying speeds based on enhancements obtained."
		textbody += " There are a set of inherent abilities you will always have while the rest may be purchased through genomes.</font><br><br>"
		textbody += "<font color='#F7F7ED'>You may obtain more genomes if you find another heretic and absorb them, but this is not required. If you've found "
		textbody += "your abilities aren't to your liking, you have up to two re-adapts available, and these may be refilled by absorbing anyone -- including monkeys.</font><br><br>"
		textbody += "<font color='#F7F7ED'>Good luck and remember, killing isn't always the end goal.</font>"
		display()

/datum/managed_browser/hereticpaths/proc/generate_abilitylist(cat)
	var/list/ability_list = list()
	var/info = ""
	var/catname = ""
	for(var/datum/power/heretic/P in GLOB.powerinstances)
		if(P.power_category == cat)
			ability_list[LIST_PRE_INC(ability_list)] = P
	switch(cat)
		if(HERETIC_POWER_GENERAL)
			catname = "Inherent"
			info = "These powers are inherent to your kind and will always be accessible, provided you have the chemicals to use them."
		if(HERETIC_POWER_FLESH)
			catname = "Armor"
			info = "These abilities will provide you with space protection -- and potentially armor."
		if(HERETIC_POWER_HUNT)
			catname = "Weapons"
			info = "These abilities will provide you the means to fight back."
		if(HERETIC_POWER_RIDDLE)
			catname = "Stings"
			info = "These abilities provide the means to sting organic beings for various effects -- though you must be close enough, and they must have exposed flesh."
		if(HERETIC_POWER_COSMOS)
			catname = "Shrieks"
			info = "These abilities enhance your vocal chords, empowering your screams."
		if(CHANGELING_POWER_HEALTH)
			catname = "Health"
			info = "These abilities will enhance your health or aid you in mending your wounds."
		if(CHANGELING_POWER_ENHANCEMENTS)
			catname = "Enhancements"
			info = "These abilities enhance you in various ways."
	create_textbody(ability_list, catname, info)

/datum/managed_browser/hereticpaths/proc/create_textbody(ability_list, cat, catinfo)
	textbody = "<tr><th><font color='#c72121'><center>[cat] Skills</font><br></th></tr>"
	textbody += "<tr><td><font color='#F7F7ED'>[catinfo]</center></font><br><hr></td></tr>"
	for(var/A in ability_list)
		var/datum/power/heretic/powerdata = A
		textbody += "<tr><td><center><font color='#c72121'><b>[initial(powerdata.name)]</b></font><br></center>"
		textbody += "<font color='#F7F7ED'>[initial(powerdata.desc)]</font><br><br>"
		textbody += "<font color='#F7F7ED'><i>[powerdata.helptext]</i></font><br>"
		if(powerdata.enhancedtext != "")
			textbody += "<font color='#F7F7ED'><b>WHEN EHANCED: </b><i>[powerdata.enhancedtext]</i></font><br>"
		if(powerdata in my_client.mob.mind.heretic.purchased_powers)
			textbody += "<center><font color='#F7F7ED'><i><b>This ability is already evolved!</b></i></font></center>"
		else if(cat != "Inherent")
			textbody += "<center><a style='background-color:#c72121;' href='?src=\ref[src];evolve=[A]'>Evolve</a></center>"
		textbody += "</td></tr>"
	display()

/// Мастер-спелл, отвечает за покупку

/datum/power/heretic
	icon = "тут путь к иконкам"
	/// Cost for the changling to evolve this power.
	var/knowledgecost = 500000
	/// _defines/gamemode.dm
	var/power_category = null


// Пощади человек-джаваскрипт

/datum/heretic/proc/EvolutionMenu()//The new one
	set category = "Changeling"
	set desc = "Level up!"

	if(!usr || !usr.mind || !usr.mind.heretic)	return
	src = usr.mind.heretic

	if(!length(powerinstances))
		for(var/P in powers)
			powerinstances += new P()

	var/dat = "<html><head><title>Changling Evolution Menu</title></head>"

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

				function expand(id,name,desc,helptext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<span style='font-size: 13px'><b>"+desc+"</b></span> <BR>"

					body += "<span style='font-size: 13px; color: red'><b>"+helptext+"</b></span><BR>"

					if(!ownsthis)
					{
						body += "<a href='byond://?src=\ref[src];P="+power+"'>Evolve</a>"
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
					notice_span.innerHTML = "<span style='color: red'>Locked</span> ";
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
					<span styly='font-size: 24px'><b>Changling Evolution Menu</b></span><br>
					Hover over a power to see more information<br>
					Current evolution points left to evolve with: [knowledgepoints]<br>
					Absorb genomes to acquire more evolution points
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
	for(var/datum/power/heretic/P in powerinstances)
		var/ownsthis = 0

		if(P in purchasedpowers)
			ownsthis = 1


		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<span id='search[i]'><b>Evolve [P] - Cost: [ownsthis ? "Purchased" : P.knowledgecost]</b></span>
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

	show_browser(usr, dat, "window=powers;size=900x480")

/// Второе такое же дерево. Помогите...

/datum/heretic/proc/EvolutionTree()//The new one
	set name = "-Evolution Tree-"
	set category = "Changeling"
	set desc = "Adapt yourself carefully."

	if(!usr || !usr.mind || !usr.mind.heretic)	return
	src = usr.mind.heretic

	if(!length(GLOB.powerinstances))
		for(var/P in powers)
			GLOB.powerinstances += new P()

	var/dat = "<html><head><title>Changeling Evolution Tree</title></head>"

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

					body += "<font size='2'><font color = 'red'><b>"+helptext+"</b></font></font><BR>"

					if(enhancedtext)
					{
						body += "<font size='2'><font color = 'blue'>Recursive Enhancement Effect: <b>"+enhancedtext+"</b></font></font><BR>"
					}

					if(!ownsthis)
					{
						body += "<a href='byond://?src=\ref[src];P="+power+"'>Evolve</a>"
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
					<font size='5'><b>Changeling Evolution Menu</b></font><br>
					Hover over a power to see more information<br>
					Current evolution points left to evolve with: [knowledgepoints]<br>
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


		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P.enhancedtext]","[P]",[ownsthis])'
					>
					<span id='search[i]'><b>Evolve [P] - Cost: [ownsthis ? "Purchased" : P.knowledgecost]</b></span>
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

	show_browser(usr, dat, "window=powers;size=900x480")

/datum/heretic/Topic(href, href_list)
	..()
	if(!ismob(usr))
		return

	if(href_list["P"])
		var/datum/mind/M = usr.mind
		if(!istype(M))
			return
		purchasePower(M, href_list["P"])
		call(TYPE_PROC_REF(/datum/heretic, EvolutionMenu))()



/datum/heretic/proc/purchasePower(datum/mind/M, Pname, remake_verbs = 1)
	if(!M || !M.heretic)
		return

	var/datum/power/heretic/Thepower = Pname


	for (var/datum/power/heretic/P in powerinstances)
//		log_debug("[P] - [Pname] = [P.name == Pname ? "True" : "False"]")

		if(P.name == Pname)
			Thepower = P
			break


	if(isnull(Thepower))
		CRASH("This is awkward.  Changeling power purchase failed, please report this bug to a coder!")
		return

	if(Thepower in purchasedpowers)
		to_chat(M.current, "We have already evolved this ability!")
		return


	if(knowledgepoints < Thepower.knowledgecost)
		to_chat(M.current, "We cannot evolve this... yet.  We must acquire more DNA.")
		return

	knowledgepoints -= Thepower.knowledgecost

	purchasedpowers += Thepower

	if(!Thepower.isVerb && Thepower.verbpath)
		call(M.current, Thepower.verbpath)()
	else if(remake_verbs)
		M.current.make_heretic()
