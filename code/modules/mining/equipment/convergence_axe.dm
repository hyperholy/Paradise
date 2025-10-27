/**********CONVERGENCE AXE**************/
/obj/item/convergence_axe
	name = "convergence assualt axe"
	desc = "add words here"
	icon = 'icons/obj/mining.dmi'
	icon_state = 'convergence_axe'
	base_icon_state = 'convergence_axe'
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
	var/force_wielded = 18
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

/obj/item/convergence_axe/proc/add_to(obj/item/convergence_axe/H, mob/living/user)
	for(var/t in H.trophies)
		var/obj/item/convergence_trophy/T = t
		if(istype(T, denied_type) || istype(src, T.denied_type))
			to_chat(user, "<span class='warning'>You can't seem to attach [src] to [H]. Maybe remove a few trophies?</span>")
			return FALSE
	if(!user.unequip(src))
		return
	forceMove(H)
	H.trophies += src
	to_chat(user, "<span class='notice'>You attach [src] to [H].</span>")
	return TRUE

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
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, "<span class='warning'>[src] is too heavy to use with one hand. You fumble and drop everything.</span>")
		user.drop_r_hand()
		user.drop_l_hand()
		return

/obj/item/convergence_axe/RangedAttack(atom/A)
	fire_laser(A)

/obj/item/convergence_axe/proc/fire_laser(atom/A)
	var/datum/beam/current_beam = src.Beam(src, A, icon_state = "solar", time = beam_uptime, max_distance = beam_length)

/obj/item/convergence_trophy
