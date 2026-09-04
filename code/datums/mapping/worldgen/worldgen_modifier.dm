// Where world/map generation modifiers lives, things such as cave noise maps, ore distribution map, river generation and other
// various fun things that will occur during world generation, mostly used by biome generation but kept as a seperate system
// so that other systems could perchance use it
/datum/worldgen_modifier
	var/name = "worldgen modifier"
	/// A list of prior generation data brought in for certain generators such as flora placement requiring a humidity map
	var/generation_data = list()
	/// Size, width and height of the affected area
	var/size = 0
	/// X location offset
	var/location_x = 0
	/// Y location offset
	var/location_y = 0
	/// Z level its occuring on
	var/location_z

/// Default noise subtype for generating some noise over a section of map
/datum/worldgen_modifier/noise
	/// Lower limit exclusion, anything at or below is rejected
	var/lower_range = 0
	/// Upper limit exclusion, anything at or above is rejected
	var/upper_range = 9
	/// Perlin noise frequency, how 'big' the noise blobs are
	var/frequency = 0.1
	/// List of turf types that we ignore on /apply_value()
	var/turf_blacklist = list()
	/// Seed for generation, if unset random 1,999999 number used
	var/seed = -1
	/// A size * size list of 0-9 chars corresponding to the noise at each tile
	var/result_map = list()

/// Called from outside, returns a result_map
/datum/worldgen_modifier/noise/proc/generate(list/data)
	if(seed == -1)
		seed = rand(1, 999999)
	generation_data = data
	generate_noise()
	. = result_map
	apply()
	return

/// Handles calling the rustlib noise generation
/datum/worldgen_modifier/noise/proc/generate_noise()
	result_map = rustlibs_perlin_generate_binary("[seed]", "[frequency]", "[size]", "[lower_range]", "[upper_range]")
	return

/// Iterate over the map subsection and if a tile matches lower/upper range send to apply_value()
/datum/worldgen_modifier/noise/proc/apply()
	for(var/turf/T in block(location_x, location_y, location_z, (size + location_x) - 1, (size + location_y) - 1, location_z))
		var/c = result_map[(size * ((T.y - location_y)) + (T.x - location_x + 1))]
		if(c > lower_range && c < upper_range)
			apply_value(T)
	return

/// Most of tile modification and tile specific rejection occurs here
/datum/worldgen_modifier/noise/proc/apply_value(turf/T)
	if(is_type_in_list(T, turf_blacklist))
		return

