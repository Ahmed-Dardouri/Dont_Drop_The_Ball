class_name MoveEvent extends Event

var _move: int
var _pressed: bool
var _power: float

func _init(move: int, pressed: bool, power: float) -> void:
	_pressed = pressed
	_move = move
	_power = power

static func invoke(move : int, value: bool, power: float):
	Events.invoke(MoveEvent.new(move, value, power))
