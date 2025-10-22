/*TODO:
what even: doom guy
		   big evil demon

weapons: chainsaw?
		 shotgun?

'abilities' L+veil shift + speedup = 2,3
			L+chainsaw charge = 2,3 (AFTER VEIL SHIFT)
			L+drake ability but lifesteal runes = 3
			CL+shotgun BLAST = 1,2,3
			L+portals appear and projectiles spew out = 1,2
			L+pylons appear and lightning zaps out of them in a radius while standing stil = 2

kind of bossfight it is: melee it in openings + survive x many stages

fight stages: 1000hp-751hp -
			  750hp-251hp
			  250hp-0hp

*/
//stages mmmm
#define STAGE_THRESHHOLD_1 1000
#define STAGE_THRESHHOLD_2 750
#define STAGE_THRESHHOLD_3 250

/mob/living/basic/exalted_zealot
	name = "Exalted Zealot"
	desc = "if i forgot to fill this in tell me"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "exaltedchainsaw"
	icon_dead = "exalted_dead" //Does not actually exist, del_on_death
	death_sound = 'sound/misc/demon_dies.ogg'
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	attack_verb_continuous = "saws"
	attack_verb_simple = "saw"
	attack_sound = 'sound/weapons/chainsaw.ogg'
	health = 1000
	maxHealth = 1000
	speed = 2
	obj_damage = 60
	melee_damage_lower = 40
	melee_damage_upper = 40
	is_ranged = TRUE
	casing_type = /obj/item/ammo_casing/energy/laser/pulse
	projectile_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	damage_coeff = list(BRUTE = 1, BURN = 2, TOX = 0, STAMINA = 0, OXY = 0)
	loot = list()
	faction = list("cult")
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/exalted
	var/return_turf = null //stands here menacingly during certain abilities, if none, just stay idle
	var/portal_turfs = list() //from where the portals that spew shit appear

/mob/living/basic/exalted_zealot/Initialize(mapload)
	. = ..()
	return_turf = get_turf(src)
	if(get_area_name(return_turf) == "Eldritch Outpost Arena")
		return_turf = return_turf //shut up
	//something loot here

/datum/ai_controller/basic_controller/exalted
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/exalted_process_attack,
		/datum/ai_planning_subtree/basic_melee_attack_subtree
	)

/datum/ai_planning_subtree/exalted_process_attack
/*
	var/attack_moves = list(
		STAGE_1 = list(/datum/ai_behavior/exalted/shotgun_blast, /datum/ai_behavior/exalted/portal_shoot),
		STAGE_2 = list(/datum/ai_behavior/exalted/shotgun_blast, /datum/ai_behavior/exalted/portal_shoot,
					   /datum/ai_behavior/exalted/zap_pylons, /datum/ai_behavior/exalted/veil_shift,
					   /datum/ai_behavior/exalted/chainsaw_charge),
		STAGE_3 = list(/datum/ai_behavior/exalted/shotgun_blast, /datum/ai_behavior/exalted/veil_shift,
					   /datum/ai_behavior/exalted/chainsaw_charge, /datum/ai_behavior/exalted/lifesteal_dodge)
	)*/
	var/attack_moves = list(
		"STAGE_1" = list(/datum/ai_behavior/exalted/shotgun_blast),
		"STAGE_2" = list(/datum/ai_behavior/exalted/shotgun_blast),
		"STAGE_3" = list(/datum/ai_behavior/exalted/shotgun_blast)
	)

/datum/ai_planning_subtree/exalted_process_attack/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return
	var/mob/living/basic/exalted_zealot/boss = controller.pawn

	if(boss.health <= STAGE_THRESHHOLD_3)
		controller.queue_behavior(pick(attack_moves["STAGE_3"]), target_key)
		return
	else if(boss.health <= STAGE_THRESHHOLD_2)
		controller.queue_behavior(pick(attack_moves["STAGE_2"]), target_key)
		return
	else if(boss.health <= STAGE_THRESHHOLD_1)
		controller.queue_behavior(pick(attack_moves["STAGE_1"]), target_key)
	return

///
/datum/ai_behavior/exalted
	action_cooldown = 1.5 SECONDS
	//stuff here that should be universal to all submoves

/// shotgun firing ability
/datum/ai_behavior/exalted/shotgun_blast
	var/casing_list = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/xray)
	action_cooldown = 1 SECONDS

/// choose a bullet type
/datum/ai_behavior/exalted/shotgun_blast/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/carbon/human/target = controller.blackboard[target_key]
	if(!target)
		return FALSE

/datum/ai_behavior/exalted/shotgun_blast/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/exalted_zealot/boss = controller.pawn
	var/mob/living/carbon/human/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	boss.icon_state = "exaltedshotgun"
	//update icon appearance to bear shotgun
	sleep(0.5 SECONDS) //warning!!!!
	var/datum/component/ranged_attacks/comp = boss.GetComponent(/datum/component/ranged_attacks)
	comp.casing_type = pick(casing_list)
	boss.RangedAttack(target) //die stupid, handled by ranged_attacks
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/exalted/shotgun_blast/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/basic/exalted_zealot/boss = controller.pawn
	boss.icon_state = "exaltedchainsaw"
	//change icon back to chainsaw
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/*
/datum/ai_behavior/exalted/portal_shoot
	action_cooldown = 15 SECONDS

/datum/ai_behavior/exalted/portal_shoot/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/carbon/human/target = controller.blackboard[target_key]
	var/mob/living/basic/exalted_zealot/boss = controller.pawn
	if(!target)
		return FALSE
	if(!boss.portal_turfs) //null if admin spawn, make new ones
		//generate new ones
		boss = boss

/datum/ai_behavior/exalted/portal_shoot/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/exalted_zealot/boss = controller.pawn
	var/mob/living/carbon/human/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/turf in boss.portal_turfs)
		//callback to indiv portal handler, makes portal, waits, launches the spear
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/exalted/portal_shoot/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	//call thing to KILL portals and spears

/datum/ai_behavior/exalted/zap_pylons

/datum/ai_behavior/exalted/veil_shift

/datum/ai_behavior/exalted/chainsaw_charge

/datum/ai_behavior/exalted/lifesteal_dodge
*/
