class_name FlagCondition extends Resource

@export var id: ID.Flag = ID.Flag.DEFAULT
## If this is false, flag must be true, if true, flag must be false. It makes
## sense, god damn it!
@export var must_be_false: bool = false
