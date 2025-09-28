extends Line2D

var queue : Array
@export var MAX_LENGTH : int
@export var main_body : Node2D
var track : bool = true

func _process(_delta):
	if track:
		var pos = _get_position()
		queue.push_front(pos)
		if queue.size() > MAX_LENGTH:
			queue.pop_back()
			
		clear_points()
		for point in queue:
			add_point(point)
	
	print(queue.size())

func _get_position():
	return main_body.global_position

func set_custom_color(col: Color) -> void:
	default_color = col

func reset_trail():
	queue.clear()
	clear_points()
