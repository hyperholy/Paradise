/*

Reasoning
	As a person who plays shaft miner and enjoys the crusher and killing big things, a whole lot
	of the viability of the run hinges on if you'll find xy mob before the 1h mark and if you can
	get its crusher trophy so you can move onto the next thing in the rather (currently) monotone
	lavaland wastes. My aim with lavaland biomes is to make the place look nicer and different
	between rounds, visually, and practically give more 'reason' behind flora, fauna, megafauna and
	ore placements that players can learn and use to their advantage to rely more on skill than rng
	for getting cool trophies

Biome template idea
	rock_type
		base wall type
	flora_list
		plant whitelist to spawn in
	fauna_list
		mobs whitelist to spawn in
	megafauna_list
		megafauna whitelist to spawn in
	generation_flags (?)
		additional generation, caves?, river?, lake? probably implemented as like a
		list of generation datum procs iteratively ran over to successively change the
		biome area, cave and lake could be noise but river would be carving water between lakes etc etc
	ambient_light
		colour of the (weak) ambient light
	weather_immunity
		which weather types are supressed in the biome
	ambient_sound
		list of sounds that could play
	ore_list
		ore spawn and weights

Biomes:
	Ashlands
		base lavaland

	Industrial wastes
		Ashlands affected by the mining industry, rivers and lakes of sulphur,
		ruins of previous mining corporations litter the place, along with their
		legioned workers. lots of legions, vetus and BDM maybe unexploded mining munitions
		abouts? maybe like sickly yellow looking floor and rock tiles, terrible ore here maybe,
		mostly mined out, occasional yellow lighting for atmosphere and rumble sfx

	Radioactive wastes
		variant of industrial wastes but slightly radioactive, radioactive sulphur too
		this time, lots of uranium to be found though

	Fracture caverns
		Tight caves, chasms but rich in plasma and diamond ores, lotsa goliath and watchers
		here, maybe seams of ancient rock i.e. pickaxe only, dim environment

	Blooming oasis
		Plant filled oasis, weak kudzu here, lots of jungle plants and kudzu mobs are
		common here, small water puddles here, maybe enclosed fully by ancient rock,
		regular lavaland mobs dont spawn here jungle tiles of course, green colours for
		atmosphere and idk for sfx

	Magma core
		Large lakes of lava with islands rich in metal, titanium, silver, gold,
		lotsa drakes however and magma wing watchers

	Bloodied boneyard (maybe change so doesnt sound like a fortnite location)
		Outcrops of large bones litter the area, fleshy weaker rock walls still have
		some ore, bubblegum and the cancerous tumour thing can be found here,
		dim red lighting and gurgles sfx

 */

/datum/biome_theme
	var/name = "backrooms"
	#warn TODO: AUTODOC!!!!!!!!
	var/seed
	var/size = 230
	var/frequency = 0.02
	var/divisor = 1
	var/octaves = 3
	var/mix = 0.25

	var/area_type = null
	var/turf_type = /turf/simulated/floor/backrooms_carpet
	var/rock_type_old = /turf/simulated/wall/indestructible/backrooms
	var/fauna_weights = list()
	var/megafauna_weights = list()
	var/flora_weights = list()
	var/liquid_type = null
	#warn TODO: pull from global list instead
	var/temp_location_x = 10
	var/temp_location_y = 10
	var/temp_location_z = null

/datum/biome_theme/New()
	seed = rand(1, 999999)

/datum/biome_theme/proc/setup()
	var/valid_zs = levels_by_trait(ORE_LEVEL)
	var/datum/biome_theme/chosen_biome = pick(subtypesof(/datum/biome_theme))
	var/datum/biome_theme/our_biome = new chosen_biome
	our_biome.temp_location_z = pick(valid_zs)
	our_biome.setup()


/datum/biome_theme/test_biome
	name = "mmm test biome"

/datum/biome_theme/test_biome/setup()
	var/result = rustlibs_perlin_generate_advanced_dlerp("[seed]", "[size]", "[frequency]", "[divisor]", "[octaves]", "[mix]")
	for(var/turf/simulated/mineral/T in block(temp_location_x, temp_location_y, temp_location_z, (size + temp_location_x) - 1, (size + temp_location_y) - 1, temp_location_z))
		if(!istype(get_area(T), /area/lavaland/surface/outdoors/unexplored))
			continue
		var/c = result[(size * ((T.y - temp_location_y)) + (T.x - temp_location_x + 1))]

		T.should_reset_color = FALSE

		if(c == "0")
			T.color = COLOR_RED
		if(c == "1")
			T.color = COLOR_DARK_ORANGE
		if(c == "2")
			T.color = COLOR_ORANGE
		if(c == "3")
			T.color = COLOR_YELLOW
		if(c == "4")
			T.color = COLOR_LIME
		if(c == "5")
			T.color = COLOR_GREEN
		if(c == "6")
			T.color = COLOR_BLUE_LIGHT
		if(c == "7")
			T.color = COLOR_BLUE
		if(c == "8")
			T.color = COLOR_DARK_BLUE_GRAY
		if(c == "9")
			T.color = COLOR_INDIGO

		//T.ChangeTurf(rock_type)
	return
