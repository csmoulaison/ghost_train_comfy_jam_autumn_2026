# NOTE: This file is a bit painful to change without handling git merges, as it 
# touches just about every systematic concern in the game. Locking down data
# like Persons and Locations would be nice to prevent some of this, but flags
# and events will need to be added to frequently, so I think this is going to
# just end up needing some merges to happen. Shouldn't be too bad, just adding
# short lines of text to lists.
class_name ID

enum Person {
	DEFAULT,
	GHOST, # this is the player, so he isn't used for most Person related functionality
	CROW,
	JACKO,
	JILLO,
	JACKOKIDS,
	SCARECROW,
	WITCH,
	OLD_OAK,
	GRIM,
	BIG_CARGO_MONSTER,
	PERSON_COUNT, # PERSON_COUNT must always be at the end of the list
}

enum Location {
	DEFAULT,
	GRAVEYARD,
	FARMERS_MARKET,
	PUMPKIN_PATCH,
	WITCHS_TRAIN_YARD,
	BNB,
	CIDER_MILL,
	HAUNTED_MANSION,
	LAKE_IN_THE_WOODS,
	CRANBERRY_BOG,
	GRIMS_GROTTO,
	CORN_MAZE,
	LOCATION_COUNT, # LOCATION_COUNT must always be at the end of the list
}

enum Flag {
	DEFAULT,
	FLAG_COUNT, # FLAG_COUNT must always be at the end of the list
}

enum Event {
	DEFAULT,
	EVENT_COUNT, # EVENT_COUNT must always be at the end of the list
}
