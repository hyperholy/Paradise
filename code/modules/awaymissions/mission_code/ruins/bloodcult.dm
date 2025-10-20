/datum/outfit/dead_cultist
	name = "Dead Cultist"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult
	head = /obj/item/clothing/head/hooded/culthood/alt
	r_hand = /obj/item/melee/cultblade/dagger

/obj/effect/mob_spawn/human/corpse/cultist
	name = "Dead Cultist"
	mob_name = "Dead Cultist"
	outfit = /datum/outfit/dead_cultist
	hair_style = "bald"

/mob/living/basic/cultist
	name = "Cultist"
	desc = "They've got a faint red eerie glow"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "cultist" //ouughh the blade is in the wrong hand, left is evil anyways
	icon_living = "cultist"
	icon_dead = "cultist_dead" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	response_help_continuous = "pushes the"
	response_help_continuous = "push the"
	response_harm_continuous = "slashes"
	response_harm_simple = "slash"
	speed = 0.5
	harm_intent_damage = 5
	obj_damage = 35
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_attack_cooldown_min = 1.0 SECONDS
	melee_attack_cooldown_max = 1.5 SECONDS
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	ai_controller = /datum/ai_controller/basic_controller/simple/cultist
	speak_emote = list("snarls")
	loot = list(/obj/effect/mob_spawn/human/corpse/cultist,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
	basic_mob_flags = DEL_ON_DEATH
	faction = list("cult")
	sentience_type = SENTIENCE_OTHER
	step_type = FOOTSTEP_MOB_SHOE

/mob/living/basic/cultist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aggro_emote, aggro_sound = pick('sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg', 'sound/hallucinations/growl3.ogg'), emote_chance = 100)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])
	set_light(2, 2, COLOR_RED)
	if(prob(50))
		loot = list(/obj/item/salvage/ruin/tablet,
			/obj/effect/mob_spawn/human/corpse/cultist,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/basic/cultist/beam //shoots a burst fire of beams
	name = "Cultist Beam Caster"
	icon_state = "cultistbeam"
	icon_living = "cultistbeam"
	is_ranged = TRUE
	ranged_cooldown = 3 SECONDS
	melee_attack_cooldown_min = 2.5 SECONDS //weaker in melee
	melee_attack_cooldown_max = 3.5 SECONDS
	projectile_type = /obj/item/projectile/beam/cult
	projectile_sound = 'sound/magic/wand_teleport.ogg'
	ranged_burst_count = 3
	var/combo_threshold = 3
	var/list/combotargets = list()
	ranged_burst_interval = 0.3 SECONDS //can block them all if well timed
	ai_controller = /datum/ai_controller/basic_controller/simple/cultist/beam
	loot = list(/obj/effect/mob_spawn/human/corpse/cultist,
				/obj/effect/decal/cleanable/blood/innards,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/gibspawner/generic,
				/obj/effect/gibspawner/generic)

/mob/living/basic/cultist/beam/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PROJ_COMBO_CHECK, PROC_REF(combo_increment))
	RegisterSignal(src, COMSIG_BASICMOB_PRE_ATTACK_RANGED, PROC_REF(combo_activate))
	if(prob(50))
		loot = list(/obj/effect/mob_spawn/human/corpse/cultist,
				/obj/effect/decal/cleanable/blood/innards,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/gibspawner/generic,
				/obj/effect/gibspawner/generic)

/mob/living/basic/cultist/beam/proc/combo_increment(parent, mob/living/carbon/human/target)
	if(!ishuman(target))
		return
	if(combotargets.Find(target) > 0)
		combotargets[target] += 1
	else
		combotargets[target] = 1

/mob/living/basic/cultist/beam/proc/combo_activate(parent, mob/living/carbon/human/target)
	sleep((ranged_burst_count * ranged_burst_interval) + 0.5 SECONDS) //cant check if a burst is done so lets estimate!
	for(var/H in combotargets)
		if(H >= combo_threshold) //same target combo_threshold times in a burst?
			combotargets.Cut(combotargets.Find(H))
			fire_projectile(/obj/item/projectile/magic/cult_heal, target, 'sound/magic/wand_teleport.ogg', src) //fuck it we do it live

/datum/ai_controller/basic_controller/simple/cultist //TODO: run to runes when low, drag dead carbons to runes
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cultist,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/cultist
	speech_chance = 10
	speak = list(
		"Aiy ele-mayo!",
		"Ra'sha yoka!",
		"Mah'weyh pleggh at e'ntrath!",
		"Barhah hra zar'garis!",
		"Sas'so c'arta forbici!",
		"H'drak v'loso, mir'kanas verbot!",
		"Khari'd! Eske'te tannin!",
		"N'ath reth sh'yro eth d'rekkathnor!",
		"Dedo ol'btoh!",
		"Gal'h'rfikk harfrandid mud'gib!")

/datum/ai_controller/basic_controller/simple/cultist/beam
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cultist,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance/cultist,
		/datum/ai_planning_subtree/ranged_skirmish/avoid_friendly,
	)

/datum/ai_planning_subtree/maintain_distance/cultist
	run_away_behavior = /datum/ai_behavior/step_away/cultist

/datum/ai_behavior/step_away/cultist //slow to back away, rush them!
	action_cooldown = 0.5 SECONDS
	required_distance = 2

/obj/item/projectile/beam/cult
	name = "eldritch beam"
	icon_state = "arcane_barrage"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 13.4 //60 damage if everything lands
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 3 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_range = 2
	light_color = LIGHT_COLOR_PURPLE

/obj/item/projectile/beam/cult/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!ishuman(target)) //dont combo count walls
		return
	if(!blocked)
		var/mob/living/carbon/human/victim = target
		SEND_SIGNAL(firer, COMSIG_PROJ_COMBO_CHECK, victim)

/obj/item/projectile/magic/cult_heal
	name = "eldritch beam"
	icon_state = null
	hitscan = TRUE
	damage = 20
	muzzle_type = /obj/effect/projectile/muzzle/death
	tracer_type = /obj/effect/projectile/tracer/death
	impact_type = /obj/effect/projectile/impact/death
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_PURPLE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_PURPLE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_PURPLE

/obj/item/projectile/magic/cult_heal/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(istype(firer, /mob/living/basic/cultist/beam) && ishuman(target)) //shooting walls shouldnt heal
		var/mob/living/basic/to_heal = firer
		to_heal.adjustHealth(-damage * 2) //heals 40

// /datum/ai_planning_subtree/maintain_distance/cultist/shotgun //shotguns are stronger closer up, why run?
