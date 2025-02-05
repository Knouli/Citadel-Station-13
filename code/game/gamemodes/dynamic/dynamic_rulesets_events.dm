/datum/dynamic_ruleset/event
	ruletype = "Event"
	var/typepath // typepath of the event
	var/triggering

/datum/dynamic_ruleset/event/execute()
	var/datum/round_event/E = new typepath()
	E.current_players = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	// E.control = src // can't be done! we just don't use events that require these, those can be from_ghost almost always

	testing("[time2text(world.time, "hh:mm:ss")] [E.type]")
	deadchat_broadcast("<span class='deadsay'><b>[name]</b> has just been triggered by dynamic!</span>")
	log_game("Random Event triggering: [name] ([typepath])")

	return E

/datum/dynamic_ruleset/event/ready(forced = FALSE) // same as midround cause we're still using enemy system
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in mode.current_players[CURRENT_LIVING_PLAYERS])
				if (M.stat == DEAD)
					continue // Dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles))
					job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return FALSE
	return TRUE

//////////////////////////////////////////////
//                                          //
//               PIRATES                    //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/pirates
	name = "Space Pirates"
	config_tag = "pirates"
	typepath = /datum/round_event/pirates
	antag_flag = ROLE_TRAITOR
	enemy_roles = list("AI","Security Officer","Head of Security","Captain")
	required_enemies = list(2,2,1,1,0,0,0,0,0,0)
	weight = 5
	cost = 10
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear,/datum/dynamic_ruleset/midround/from_ghosts/nuclear)
	requirements = list(70,60,50,50,40,40,40,30,20,15)
	high_population_requirement = 15

/datum/dynamic_ruleset/event/pirates/ready(forced = FALSE)
	if (!SSmapping.empty_space)
		return FALSE
	return ..()

//////////////////////////////////////////////
//                                          //
//               SPIDERS                    //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/spiders
	name = "Spider Infestation"
	config_tag = "spiders"
	typepath = /datum/round_event/spider_infestation
	enemy_roles = list("AI","Security Officer","Head of Security","Captain")
	required_enemies = list(2,2,1,1,0,0,0,0,0,0)
	weight = 5
	cost = 10
	requirements = list(70,60,50,50,40,40,40,30,20,15)
	high_population_requirement = 15

//////////////////////////////////////////////
//                                          //
//              CLOGGED VENTS               //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/ventclog
	name = "Clogged Vents"
	config_tag = "ventclog"
	typepath = /datum/round_event/vent_clog
	enemy_roles = list("Chemist","Medical Doctor","Chief Medical Officer")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	cost = 2
	weight = 4
	repeatable_weight_decrease = 3
	requirements = list(5,5,5,5,5,5,5,5,5,5) // yes, can happen on fake-extended
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/ventclog/ready()
	if(mode.threat_level > 30 && mode.threat >= 5 && prob(20))
		name = "Clogged Vents: Threatening"
		cost = 5
		required_enemies = list(3,3,3,2,2,2,1,1,1,1)
		typepath = /datum/round_event/vent_clog/threatening
	else if(mode.threat_level > 15 && mode.threat > 15 && prob(30))
		name = "Clogged Vents: Catastrophic"
		cost = 15
		required_enemies = list(2,2,1,1,1,1,0,0,0,0)
		typepath = /datum/round_event/vent_clog/catastrophic
	else
		cost = 2
		name = "Clogged Vents: Normal"
		required_enemies = list(1,1,1,0,0,0,0,0,0,0)
		typepath = /datum/round_event/vent_clog
	return ..()

//////////////////////////////////////////////
//                                          //
//               ION STORM                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/ion_storm
	name = "Ion Storm"
	config_tag = "ion_storm"
	typepath = /datum/round_event/ion_storm
	enemy_roles = list("Research Director","Captain","Chief Engineer")
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	weight = 4
	// no repeatable weight decrease. too variable to be unfun multiple times in one round
	cost = 3
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

//////////////////////////////////////////////
//                                          //
//                METEORS                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/meteor_wave
	name = "Meteor Wave"
	config_tag = "meteor_wave"
	typepath = /datum/round_event/meteor_wave
	enemy_roles = list("Chief Engineer","Station Engineer","Atmospheric Technician","Captain","Cyborg")
	required_enemies = list(3,3,3,3,3,3,3,3,3,3)
	cost = 15
	weight = 3
	repeatable_weight_decrease = 2
	requirements = list(60,50,40,30,30,30,30,30,30,30)
	high_population_requirement = 30
	repeatable = TRUE

/datum/dynamic_ruleset/event/meteor_wave/ready()
	if(mode.threat_level > 40 && mode.threat >= 25 && prob(20))
		cost = 25
		typepath = /datum/round_event/meteor_wave/threatening
	else if(mode.threat_level > 50 && mode.threat >= 40 && prob(30))
		cost = 40
		typepath = /datum/round_event/meteor_wave/catastrophic
	else
		cost = 15
		typepath = /datum/round_event/meteor_wave
	return ..()

//////////////////////////////////////////////
//                                          //
//               ANOMALIES                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/anomaly_bluespace
	name = "Anomaly: Bluespace"
	config_tag = "anomaly_bluespace"
	typepath = /datum/round_event/anomaly/anomaly_bluespace
	enemy_roles = list("Chief Engineer","Station Engineer","Atmospheric Technician","Research Director","Scientist","Captain")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	weight = 2
	repeatable_weight_decrease = 1
	cost = 3
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/anomaly_flux
	name = "Anomaly: Hyper-Energetic Flux"
	config_tag = "anomaly_flux"
	typepath = /datum/round_event/anomaly/anomaly_flux
	enemy_roles = list("Chief Engineer","Station Engineer","Atmospheric Technician","Research Director","Scientist","Captain")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	weight = 2
	repeatable_weight_decrease = 1
	cost = 5
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 10
	repeatable = TRUE

/datum/dynamic_ruleset/event/anomaly_gravitational
	name = "Anomaly: Gravitational"
	config_tag = "anomaly_gravitational"
	typepath = /datum/round_event/anomaly/anomaly_grav
	weight = 2
	repeatable_weight_decrease = 1
	cost = 3
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/anomaly_pyroclastic
	name = "Anomaly: Pyroclastic"
	config_tag = "anomaly_pyroclastic"
	typepath = /datum/round_event/anomaly/anomaly_pyro
	weight = 2
	repeatable_weight_decrease = 1
	cost = 5
	enemy_roles = list("Chief Engineer","Station Engineer","Atmospheric Technician","Research Director","Scientist","Captain","Cyborg")
	required_enemies = list(1,1,1,1,1,1,1,1,1,1)
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE

/datum/dynamic_ruleset/event/anomaly_vortex
	name = "Anomaly: Vortex"
	config_tag = "anomaly_vortex"
	typepath = /datum/round_event/anomaly/anomaly_vortex
	weight = 2
	repeatable_weight_decrease = 1
	cost = 5
	enemy_roles = list("Chief Engineer","Station Engineer","Atmospheric Technician","Research Director","Scientist","Captain","Cyborg")
	required_enemies = list(1,1,1,1,1,1,1,1,1,1)
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE

//////////////////////////////////////////////
//                                          //
//        WOW THAT'S A LOT OF EVENTS        //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/event/brand_intelligence
	name = "Brand Intelligence"
	config_tag = "brand_intelligence"
	typepath = /datum/round_event/brand_intelligence
	weight = 1
	repeatable_weight_decrease = 1
	cost = 2
	enemy_roles = list("Chief Engineer","Station Engineer","Atmospheric Technician","Research Director","Scientist","Captain","Cyborg")
	required_enemies = list(1,1,1,1,0,0,0,0,0,0)
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE

/datum/dynamic_ruleset/event/carp_migration
	name = "Carp Migration"
	config_tag = "carp_migration"
	typepath = /datum/round_event/carp_migration
	weight = 7
	repeatable_weight_decrease = 3
	cost = 4
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE

/datum/dynamic_ruleset/event/communications_blackout
	name = "Communications Blackout"
	config_tag = "communications_blackout"
	typepath = /datum/round_event/communications_blackout
	cost = 4
	weight = 2
	repeatable_weight_decrease = 3
	enemy_roles = list("Chief Engineer","Station Engineer")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/processor_overload
	name = "Processer Overload"
	config_tag = "processor_overload"
	typepath = /datum/round_event/processor_overload
	cost = 4
	weight = 2
	repeatable_weight_decrease = 3
	enemy_roles = list("Chief Engineer","Station Engineer")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/space_dust
	name = "Minor Space Dust"
	config_tag = "space_dust"
	typepath = /datum/round_event/space_dust
	cost = 2
	weight = 2
	repeatable_weight_decrease = 1
	enemy_roles = list("Chief Engineer","Station Engineer")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/major_dust
	name = "Major Space Dust"
	config_tag = "major_dust"
	typepath = /datum/round_event/meteor_wave/major_dust
	cost = 4
	weight = 2
	repeatable_weight_decrease = 1
	enemy_roles = list("Chief Engineer","Station Engineer")
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE

/datum/dynamic_ruleset/event/electrical_storm
	name = "Electrical Storm"
	config_tag = "electrical_storm"
	typepath = /datum/round_event/electrical_storm
	cost = 1
	weight = 2
	repeatable_weight_decrease = 1
	enemy_roles = list("Chief Engineer","Station Engineer")
	required_enemies = list(1,1,1,0,0,0,0,0,0,0)
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/heart_attack
	name = "Random Heart Attack"
	config_tag = "heart_attack"
	typepath = /datum/round_event/heart_attack
	cost = 3
	weight = 2
	repeatable_weight_decrease = 1
	enemy_roles = list("Medical Doctor","Chief Medical Officer")
	required_enemies = list(2,2,2,2,2,2,2,2,2,2)
	requirements = list(101,101,101,5,5,5,5,5,5,5)
	high_population_requirement = 5
	repeatable = TRUE

/datum/dynamic_ruleset/event/radiation_storm
	name = "Radiation Storm"
	config_tag = "radiation_storm"
	typepath = /datum/round_event/radiation_storm
	cost = 3
	weight = 1
	enemy_roles = list("Chemist","Chief Medical Officer","Geneticist","Medical Doctor","AI","Captain")
	required_enemies = list(1,1,1,1,1,1,1,1,1,1)
	requirements = list(5,5,5,5,5,5,5,5,5,5)
	high_population_requirement = 5
