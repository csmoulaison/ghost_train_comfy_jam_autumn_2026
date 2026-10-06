class_name PersonLocationCondition extends Resource

@export var person: ID.Person = ID.Person.DEFAULT
@export var location: ID.Location = ID.Location.DEFAULT
@export var must_not_be_in_location: bool = false
