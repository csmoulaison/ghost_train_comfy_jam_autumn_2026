extends Node

# to emit signal: EventBus.event_signal.emit(ID.Event.MY_EVENT_NAME, 0)
# 	optionally, pass an integer for extra info, which could be an enum value.
# to listen for signal: EventBus.event_signal.connect(_my_function_name)
# 	_my_function_name must have signature: function(event: ID.Event, arg: int)
signal event_signal(event: ID.Event, arg: int)
