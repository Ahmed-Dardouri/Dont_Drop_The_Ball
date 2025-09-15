extends Node2D

@onready var knob: Sprite2D = $Knob

var posVector: Vector2
@export var deadzone = 15
@export var maxLength = 100

var pressing = false

func _process(delta):
	var touch_pos = get_viewport().get_mouse_position()
	if pressing:
		if touch_pos.distance_to(global_position) <= maxLength:
			knob.global_position.x = touch_pos.x
		else:
			var angle = global_position.angle_to_point(touch_pos)
			knob.global_position.x = global_position.x + cos(angle)*maxLength
			# global_position.y = parent.global_position.y + sin(angle)*maxLength
		calculateVector()
	else:
		knob.global_position.x = lerp(knob.global_position.x, global_position.x, delta*50)
		posVector = Vector2(0,0)
		
func calculateVector():
	if abs((knob.global_position.x - global_position.x)) >= deadzone:
		posVector.x = (knob.global_position.x - global_position.x)/maxLength
	# if abs((global_position.y - parent.global_position.y)) >= deadzone:
	# 	parent.posVector.y = (global_position.y - parent.global_position.y)/maxLength
		


func _on_button_pressed() -> void:
	pressing = true
	print("press")


func _on_button_released() -> void:
	pressing = false
	print("pressnt")
