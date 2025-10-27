/**********CONVERGENCE AXE**************/
/obj/item/convergence_axe
	name = "convergence assualt axe"
	desc = "add words here"
	icon = 'icons/obj/mining.dmi'
	icon_state = "convergence_axe"
	base_icon_state = "convergence_axe"
	inhand_icon_state = "crusher0"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	throw_speed = 4
	armor_penetration_flat = 10
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("smashed", "crushed", "cleaved", "chopped", "pulped")
	sharp = TRUE
	new_attack_chain = TRUE
	actions_types = list(/datum/action/item_action/toggle_light)
	var/list/trophies = list()
	var/list/beamed_turfs = list()
	var/force_wielded = 18
	var/datum/beam/current_beam
	var/beam_length = 3
	var/beam_uptime = 5 SECONDS

/obj/item/convergence_axe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = MELEE_ATTACK, _parry_cooldown = (10 / 3) SECONDS, _requires_two_hands = TRUE) // 2.3333 seconds of cooldown for 30% uptime
	AddComponent(/datum/component/two_handed, force_wielded = force_wielded, force_unwielded = force)

/obj/item/convergence_axe/Destroy()
	QDEL_LIST_CONTENTS(trophies)
	return ..()

/obj/item/convergence_axe/examine(mob/living/user)
	. = ..()
	// fill shit in later

/obj/item/convergence_axe/attack_by(obj/item/I, mob/user)
	if(istype(I, /obj/item/convergence_trophy))
		var/obj/item/convergence_trophy/T = I
		T.add_to(src, user)
	else
		return ..()

/obj/item/convergence_axe/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(LAZYLEN(trophies))
		to_chat(user, "<span class='notice'>You remove [src]'s trohpies.</span>")
		for(var/t in trophies)
			var/obj/item/convergence_trophy/T = t
			T.remove_from(src, user)
	else
		to_chat(user, "<span class=warning'>There are no trophies on [src].</span>")

/obj/item/convergence_axe/attack(mob/living/target, mob/living/user)
	if(..())
		return FINISH_ATTACK
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, "<span class='warning'>[src] is too heavy to use with one hand. You fumble and drop everything.</span>")
		user.drop_r_hand()
		user.drop_l_hand()
		return FALSE
	return ..()

/obj/item/convergence_axe/ranged_interact_with_atom(atom/target, mob/living/user)
	. = ..()
	fire_laser(target, user)


/obj/item/convergence_axe/proc/fire_laser(atom/target, mob/living/user)
	current_beam = Beam(target, "tracer_beam", 'icons/obj/projectiles_tracer.dmi', beam_uptime, maxdistance = 10, clip_distance = beam_length, use_get_turf = TRUE)
	if(length(beamed_turfs) > 0)
		handle_convergence(target)
	for(var/b in current_beam.elements)
		var/turf/t = get_turf(b)
		if(beamed_turfs.Find(t) > 0)
			beamed_turfs[t] += 1
		else
			beamed_turfs[t] = 1

/obj/item/convergence_axe/proc/handle_convergence(atom/target)
	var/total_convergences = 0
	var/turf/special_turf
	for(var/turf/T in beamed_turfs)
		if(beamed_turfs[T] > 1)
			total_convergences += 1
			special_turf = T
	if(total_convergences > 1) // must hit at least one
		beamed_turfs.Cut()
		return
	for(var/mob/living/dietarget in special_turf)
		if(ismob(dietarget))
			dietarget.gib()
			beamed_turfs.Cut()
	//do shit here

/obj/item/convergence_trophy
	name = "magenta and black trophy"
	desc = "If you are reading this make an issue report on Github"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "tail_spike"
	var/denied_type = /obj/item/convergence_trophy

/obj/item/convergence_trophy/examine(mob/living/user)
	. = ..()
	. += "<span class='notice'>Does [effect_desc()] when attached to a convergence assualt axe"

/obj/item/convergence_trophy/proc/effect_desc()
	return "errors"

/obj/item/convergence_trophy/attack_by(obj/item/A, mob/living/user)
	if(istype(A, /obj/item/convergence_axe))
		add_to(A, user)
	else
		..()

/obj/item/convergence_trophy/proc/add_to(obj/item/convergence_axe/H, mob/living/user)
	for(var/t in H.trophies)
		var/obj/item/convergence_trophy/T = t
		if(istype(T, denied_type) || istype(src, T.denied_type))
			to_chat(user, "<span class='warning'>You can't seem to attach[src] to [H]. Maybe remove a few trophies?</span>")
			return FALSE
	if(!user.unequip(src))
		return
	forceMove(H)
	H.trophies += src
	to_chat(user, "<span class='notice'>You attach [src] to [H].</span>")
	return TRUE

/obj/item/convergence_trophy/proc/remove_from(obj/item/convergence_axe/H, mob/living/user)
	forceMove(get_turf(H))
	H.trophies -= src
	return TRUE

/obj/item/convergence_trophy/Destroy()
	if(istype(loc, /obj/item/convergence_axe))
		var/obj/item/convergence_axe/axe = loc
		axe.trophies -= src
	return ..()
