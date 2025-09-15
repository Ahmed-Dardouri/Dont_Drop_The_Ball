extends Sprite2D

@onready var parent = $".."

var pressing = false

@export var maxLength = 50
var deadzone = 15

func _ready():
	deadzone = parent.deadzone
	maxLength = parent.maxLength

func _process(delta):
	var touch_pos = get_viewport().get_mouse_position()
	if pressing:
		if touch_pos.distance_to(parent.global_position) <= maxLength:
			global_position.x = touch_pos.x
		else:
			var angle = parent.global_position.angle_to_point(touch_pos)
			global_position.x = parent.global_position.x + cos(angle)*maxLength
			# global_position.y = parent.global_position.y + sin(angle)*maxLength
		calculateVector()
	else:
		global_position = lerp(global_position, parent.global_position, delta*50)
		parent.posVector = Vector2(0,0)
		
func calculateVector():
	if abs((global_position.x - parent.global_position.x)) >= deadzone:
		parent.posVector.x = (global_position.x - parent.global_position.x)/maxLength
	# if abs((global_position.y - parent.global_position.y)) >= deadzone:
	# 	parent.posVector.y = (global_position.y - parent.global_position.y)/maxLength
		


func _on_button_pressed() -> void:
	pressing = true
	print("press")


func _on_button_released() -> void:
	pressing = false
	print("pressnt")
