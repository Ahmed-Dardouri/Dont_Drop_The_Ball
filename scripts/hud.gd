extends CanvasLayer

@onready var button_controls: Control = $button_controls
@onready var fps_label: Label = $FPSLabel


func _process(_delta: float) -> void:
	if fps_label != null:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
