class_name MoveEvent extends Event

var _move: int
var _pressed: bool

func _init(move: int, pressed: bool) -> void:
	_pressed = pressed
	_move = move
