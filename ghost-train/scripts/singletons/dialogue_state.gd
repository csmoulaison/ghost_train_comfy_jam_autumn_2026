extends Node

# TODO: find references to the dialogue overlay and whatever else we need to
# start it going.

func start_dialogue(chain: DialogueChain):
	# TODO: I think we can basically hand control over to the overlay itself
	# from here, and then the dialogue overlay can call 
	# DialogueState.end_dialogue once it's done.
	pass

func end_dialogue():
	# TODO: Deactivate the dialogue overlay. If we've implemented a post event
	# field in the dialogue chain, fire the signal throught the EventBus.
	pass
