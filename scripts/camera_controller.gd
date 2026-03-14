extends Node2D
## Adjusts camera zoom based on device type (mobile vs desktop).

@export var desktop_zoom: Vector2 = Vector2(1.8, 1.8)
@export var mobile_zoom: Vector2 = Vector2(2.5, 2.5)

@onready var phantom_camera: Node2D = $PhantomCamera2D


func _ready() -> void:
	_adjust_zoom_for_device()


func _adjust_zoom_for_device() -> void:
	if phantom_camera == null:
		return

	# Detect if we're on a mobile device
	var is_mobile: bool = _is_mobile_device()

	var target_zoom: Vector2 = mobile_zoom if is_mobile else desktop_zoom
	phantom_camera.zoom = target_zoom


func _is_mobile_device() -> bool:
	# Check for touch screen capability as a proxy for mobile
	# Also check OS
	var os_name: String = OS.get_name()

	# Mobile platforms
	if os_name in ["Android", "iOS", "Web"]:
		# For Web, check if it has touch capability
		if os_name == "Web":
			return DisplayServer.is_touchscreen_available()
		return true

	# Desktop with touch screen - treat as mobile if touch is available
	# This handles tablets and touch-enabled laptops
	if DisplayServer.is_touchscreen_available():
		return true

	return false
