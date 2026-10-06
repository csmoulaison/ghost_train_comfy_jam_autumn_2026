# NOTE: This file is a bit painful to change without handling git merges, as it 
# touches just about every systematic concern in the game. Locking down data
# like Persons and Locations would be nice to prevent some of this, but flags
# and events will need to be added to frequently, so I think this is going to
# just end up needing some merges to happen. Shouldn't be too bad, just adding
# short lines of text to lists.
class_name ID

# Different value for each jackokid
enum Person {
	DEFAULT,
	GHOST, # this is the player, so he isn't used for most Person related functionality
	CROW,
	JACKO,
	JILLO,
	WITCH,
	SCARECROW,
	BEES,
	FISH,
	SHROOM,
	GRIMM,
	OL_APPLE,
	JACKOKID_1,
	JACKOKID_2,
	JACKOKID_3,
	JACKOKID_4,
	JACKOKID_5,
	JACKOKID_6,
	JACKOKID_7,
	JACKOKID_8,
	JACKOKID_9,
	JACKOKID_10,
	PERSON_COUNT, # PERSON_COUNT must always be at the end of the list
}

enum Location {
	DEFAULT,
	GRAVEYARD,
	FARMERS_MARKET,
	PUMPKIN_PATCH,
	WITCHS_TRAIN_YARD,
	CORN_TOWN,
	LAKE_OF_OAKS,
	SCHOOLYARD,
	FUNGI_FOREST,
	GRIMMS_GROTTO,
	LOCATION_COUNT, # LOCATION_COUNT must always be at the end of the list
}

enum Road {
	DEFAULT,
	GRAVEYARD_TO_FARMERS_MARKET,
	FARMERS_MARKET_TO_PUMPKIN_PATCH,
	FARMERS_MARKET_TO_CORN_TOWN,
	FARMERS_MARKET_TO_WITCHS_TRAIN_YARD,
	PUMPKIN_PATCH_TO_LAKE_OF_OAKS,
	WITCHS_TRAIN_YARD_TO_CORN_TOWN,
	CORN_TOWN_TO_LAKE_OF_OAKS,
	CORN_TOWN_TO_SCHOOLYARD,
	LAKE_OF_OAKS_TO_FUNGI_FOREST,
	SCHOOLYARD_TO_GRIMMS_GROTTO,
	ROAD_COUNT, # ROAD_COUNT must always be at the end of the list
}

enum Cargo {
	DEFAULT,
	PUMPKINS,
	CORN,
	APPLES,
	HONEY,
	SHROOMS,
	BOOK,
	GUITAR,
	SCYTHE,
	CARGO_COUNT,
}

enum Flag {
	DEFAULT,
	JACKOKIDS_SNUCK_ON_TRAIN, # the first time they sneak on at pumpkin patch
	FLAG_COUNT, # FLAG_COUNT must always be at the end of the list
}

enum Event {
	DEFAULT,
	OPEN_MAP,
	START_TRAVEL,
	EVENT_COUNT, # EVENT_COUNT must always be at the end of the list
}

enum Cinematic {
	DEFAULT,
	INTRO_1,
	CINEMATIC_COUNT,
}
