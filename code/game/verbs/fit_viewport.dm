/client/verb/fit_viewport()
	set name = "Fit Viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/sizes = params2list(winget(src, "mainwindow.mainvsplit;mapwindow", "size"))
	var/map_size = splittext(sizes["mapwindow.size"], "x")
	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["mainwindow.mainvsplit.size"], "x")
	var/split_width = text2num(split_size[1])

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "mainwindow.mainvsplit", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "mapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "mainwindow.mainvsplit", "splitter=[pct]")

/client/verb/fix_chat()
	set name = "Fix Chat"
	set category = "OOC"
	if (!chatOutput || !istype(chatOutput))
		var/action = alert(src, "Invalid Chat Output data found!\nRecreate data?", "Wot?", "Recreate Chat Output data", "Cancel")
		if (action != "Recreate Chat Output data")
			return
		chatOutput = new /chatOutput (src)
		chatOutput.start()
		action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum")
		else
			chatOutput.load()
			action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", "is-visible=true;is-disabled=false")
					winset(src, "browseroutput", "is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after recreating the chatOutput and forcing a load()")

	else if (chatOutput.loaded)
		var/action = alert(src, "ChatOutput seems to be loaded\nDo you want me to force a reload, wiping the chat log or just refresh the chat window because it broke/went away?", "Hmmm", "Force Reload", "Refresh", "Cancel")
		switch (action)
			if ("Force Reload")
				chatOutput.loaded = FALSE
				chatOutput.start() //this is likely to fail since it asks , but we should try it anyways so we know.
				action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a start()")
				else
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a start() and forcing a load()")

			if ("Refresh")
				chatOutput.showChat()
				action = alert(src, "Goon chat refreshing, wait a bit and tell me if it's fixed", "", "Fixed", "Nope, force a reload")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a show()")
				else
					chatOutput.loaded = FALSE
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment)", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a show() and forcing a load()")
		return

	else
		chatOutput.start()
		var/action = alert(src, "Manually loading Chat, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start()")
		else
			chatOutput.load()
			alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start() and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", list2params(list("on-show" = "", "is-disabled" = "false", "is-visible" = "true")))
					winset(src, "browseroutput", "is-disabled=true;is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after manually calling start() and forcing a load()")