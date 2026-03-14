extends Node2D
## Adjusts PhantomCamera2D properties based on device type (mobile vs desktop).
## Works with the Phantom Camera plugin to adjust zoom and offset together.

#region Exported Properties

## Desktop camera settings
@export var desktop_zoom: Vector2 = Vector2(1, 1)
@export var desktop_follow_offset: Vector2 = Vector2(0, -220)

## Mobile camera settings (more zoomed in, adjusted offset to show ground)
@export var mobile_zoom: Vector2 = Vector2(2.5, 2.5)
@export var mobile_follow_offset: Vector2 = Vector2(0, -100)

#endregion

#region Node References

@onready var phantom_camera: PhantomCamera2D = $PhantomCamera2D

#endregion


func _ready() -> void:
	_adjust_camera_for_device()


func _adjust_camera_for_device() -> void:
	if phantom_camera == null:
		return

	var is_mobile: bool = _is_mobile_device()

	var target_zoom: Vector2 = mobile_zoom if is_mobile else desktop_zoom
	var target_offset: Vector2 = mobile_follow_offset if is_mobile else desktop_follow_offset

	# Set PhantomCamera2D properties
	phantom_camera.zoom = target_zoom
	phantom_camera.follow_offset = target_offset


func _is_mobile_device() -> bool:
	var os_name: String = OS.get_name()

	# Mobile platforms
	if os_name in ["Android", "iOS", "Web"]:
		# For Web, check if it has touch capability
		if os_name == "Web":
			return DisplayServer.is_touchscreen_available()
		return true

	# Desktop with touch screen - treat as mobile if touch is available
	if DisplayServer.is_touchscreen_available():
		return true

	return false
