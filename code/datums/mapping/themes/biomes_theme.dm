// wooo

/datum/biome_theme
	var/name = "backrooms"
	#warn TODO: AUTODOC!!!!!!!!
	var/seed
	var/size = 96
	var/frequency = 1
	var/divisor = 1
	var/octaves = 3
	var/mix = 0.5

	var/area_type = null
	var/turf_type = /turf/simulated/floor/backrooms_carpet
	var/rock_type = /turf/simulated/wall/indestructible/backrooms
	var/fauna_weights = list()
	var/megafauna_weights = list()
	var/flora_weights = list()
	var/liquid_type = null
	#warn TODO: pull from global list instead
	var/temp_location_x = 128
	var/temp_location_y = 128
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
	for(var/turf/T in block(temp_location_x, temp_location_y, temp_location_z, (size + temp_location_x) - 1, (size + temp_location_y) - 1, temp_location_z))
		if(!istype(get_area(T), /area/lavaland/surface/outdoors/unexplored))
			continue
		if(!istype(T, /turf/simulated/mineral))
			continue
		var/c = result[(size * ((T.y - temp_location_y)) + (T.x - temp_location_x + 1))]
		if(c == "1")
			T.ChangeTurf(rock_type)
