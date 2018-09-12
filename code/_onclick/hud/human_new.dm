/proc/generateButtons(icon, icon_plate)
	var/list/buttons = icon_states(icon) - icon_plate
	for(var/b in buttons)
		buttons[b] = new /icon(icon, b)
	return buttons

/datum/hud/proc/human_hud_new()
	for(var/path in subtypesof(/obj/screen/movable/human_hud))
		new path(src)
	mymob.client.screen += adding
	mymob.client.screen += mymob.client.void

/obj/screen/movable/human_hud
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	//icon = 'icons/mob/hud/human_hud.dmi'

/obj/screen/movable/human_hud/New(datum/hud/mobHud)
	..()
	mobHud.adding += src

/obj/screen/movable/human_hud/MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"])
		return ..()

/obj/screen/movable/human_hud/actions
	name = "actions"
	icon = 'icons/mob/hud/hud_action2.dmi'
	icon_state = "plate"
	screen_loc = ui_acti
	var/static/list/buttons
	var/states = 0

/obj/screen/movable/human_hud/actions/New(datum/hud/mobHud)
	if(!buttons)
		buttons = generateButtons(icon, icon_state)
	var/mob/living/carbon/human/H = mobHud.mymob
	overlays += buttons[H.m_intent]
	if(H.in_throw_mode)
		overlays += buttons["throw"]
	return ..()

/obj/screen/movable/human_hud/actions/proc/toggle_state(over_icon, toggling, state = 0)
	if(toggling)
		overlays -= over_icon
	else
		overlays += over_icon
	if(state)
		states ^= state

/obj/screen/movable/human_hud/actions/Click(location,control,params)
	var/list/modifiers = params2list(params)
	var/p_x = text2num(modifiers["icon-x"])
	var/p_y = text2num(modifiers["icon-y"])
	var/mob/living/carbon/human/H = usr
	if(!(p_x in 3 to 40))
		return
	switch(p_y)
		if(81 to 89)
			toggle_state(buttons["throw"], states & H_THROW, H_THROW)
			H.toggle_throw_mode()
		if(70 to 78)
			H.client.drop_item()
		if(59 to 67)
			H.stop_pulling()
	if(p_x < 16)
		return
	switch(p_y)
		if(48 to 56)
			H.give()
		if(37 to 45)
			if(states & H_WALK)
				if(H.legcuffed)
					to_chat(H, "<span class='notice'>You are legcuffed! You cannot run until you get [H.legcuffed] removed!</span>")
					return
				overlays -= buttons[H.m_intent]
				H.m_intent = "run"
				overlays += buttons[H.m_intent]
			else
				overlays -= buttons[H.m_intent]
				H.m_intent = "walk"
				overlays += buttons[H.m_intent]
			states ^= H_WALK
		if(26 to 34)
			var/obj/item/I = H.get_active_hand()
			if(I && !I.abstract)
				I.showoff(H)
		if(15 to 23)
			H.lay_down()
		if(4 to 12)
			H.crawl()

/obj/screen/movable/human_hud/actions/update_icon(mob/mymob, state)
	switch(state)
		if(H_PULL)
			toggle_state(buttons["pull"], mymob.pulling)


/obj/screen/movable/human_hud/zone_sel
	name = "damage zone"
	icon = 'icons/mob/hud/zone_sel.dmi'
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_CHEST

/obj/screen/movable/human_hud/zone_sel/Click(location,control,params)
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(modifiers["icon-x"])
	var/icon_y = text2num(modifiers["icon-y"])
	var/old_selecting = selecting
	switch(icon_y)
		if(6 to 16) //Legs
			switch(icon_x)
				if(11 to 14)
					selecting = BP_R_LEG
				if(16 to 19)
					selecting = BP_L_LEG
		if(14 to 26) //Arms, chest and groin
			switch(icon_x)
				if(5 to 11)
					selecting = BP_R_ARM
				if(12 to 18)
					if(icon_y in 14 to 17)
						selecting = BP_GROIN
					else
						selecting = BP_CHEST
				if(19 to 25)
					selecting = BP_L_ARM
		if(26 to 33) // Head, eyes and mouth
			if(icon_x in 12 to 28)
				selecting = BP_HEAD
				switch(icon_y)
					if(26 to 28)
						if(icon_x in 13 to 17)
							selecting = O_MOUTH
					if(29 to 31)
						if(icon_x in 14 to 16)
							selecting = O_EYES

	if(old_selecting != selecting)
		update_icon()

/obj/screen/movable/human_hud/zone_sel/New(datum/hud/mobHud)
	mobHud.mymob.zone_sel = src
	update_icon()
	return ..()

/obj/screen/movable/human_hud/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/hud/zone_sel.dmi', "[selecting]")

/obj/screen/movable/human_hud/intents
	name = "intents"
	icon = 'icons/mob/hud/intents.dmi'
	icon_state = I_HELP
	screen_loc = ui_acti

/obj/screen/movable/human_hud/intents/New(datum/hud/mobHud)
	icon_state = mobHud.mymob.a_intent
	return ..()

/obj/screen/movable/human_hud/intents/Click(location,control,params)
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(modifiers["icon-x"])
	var/icon_y = text2num(modifiers["icon-y"])
	var/mob/living/carbon/human/H = usr
	switch(icon_y)
		if(7 to 15)
			switch(icon_x)
				if(7 to 27)
					H.a_intent = I_HURT
				if(31 to 57)
					H.a_intent = I_DISARM
		if(17 to 25)
			switch(icon_x)
				if(8 to 26)
					H.a_intent = I_HELP
				if(35 to 53)
					H.a_intent = I_GRAB

/obj/screen/movable/human_hud/resist
	name = "Resist"
	icon = 'icons/mob/hud/resist.dmi'
	icon_state = "resist"
	screen_loc = ui_pull_resist

/obj/screen/movable/human_hud/resist/Click(location, control, params)
	var/mob/living/L = usr
	L.resist()

/obj/screen/movable/human_hud/crafting
	name = "Craft"
	icon = 'icons/mob/hud/crafting.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/movable/human_hud/crafting/Click(location, control, params)
	var/mob/living/M = usr
	M.OpenCraftingMenu()

/obj/screen/movable/human_hud/health
	name = "The Health"
	icon = 'icons/mob/hud/health.dmi'
	icon_state = "health7"
	screen_loc = ui_health

/obj/screen/movable/human_hud/health/New(datum/hud/mobHud)
	..()
	mobHud.mymob.healths = src

/obj/screen/movable/human_hud/healthDoll
	name = "Health Doll"
	icon = 'icons/mob/hud/healthDoll.dmi'
	icon_state = "healthdoll_OVERLAY"
	screen_loc = ui_healthdoll

/obj/screen/movable/human_hud/healthDoll/New(datum/hud/mobHud)
	..()
	mobHud.mymob.healthdoll = src

/obj/screen/movable/human_hud/internal
	name = "internal"
	icon = 'icons/mob/hud/health.dmi'
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/movable/human_hud/internal/New(datum/hud/mobHud)
	..()
	mobHud.mymob.internals = src


/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
				usr.next_move = world.time+2
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
				usr.next_move = world.time+2
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand()
				usr.update_inv_r_hand()
				usr.next_move = world.time+6
	return 1