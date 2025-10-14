/*TODO:
what even: doom guy
		   big evil demon

weapons: chainsaw?
		 shotgun?
		 cult spear?

'abilities' veil shift
			slow fireball turrets
			spawn constructs/shades
			drake ability but lifesteal runes
			terror prince lunge
			portals appear and projectiles spew out
			anyway yeah my only suggests are blood/lightning
			 storm while standing still and I guess some patches
			  of flooring turning into lava temporarily like drake, but much smaller radius

kind of bossfight it is: ranged dodge (colossus)
						 melee it in openings
						 survive x many stages


*/
/mob/living/basic/exalted_zealot
	name = "Exalted Zealot"
	desc = "if i forgot to fill this in tell me"
	icon = "fill this in"
	icon_state ="exaltedzealot"
	icon_dead = "exaltedzealot_dead" //Does not actually exist, del_on_death
	death_sound = 'something'
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	attack_verb_continuous =
	attack_verb_simple =
	attack_sound =
	speed = 3
	obj_damage = 60
	melee_damage_lower = 40
	melee_damage_upper = 40
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	loot = list()


