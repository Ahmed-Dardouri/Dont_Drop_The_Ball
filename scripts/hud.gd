extends CanvasLayer

@onready var button_controls: Control = $button_controls
@onready var fps_label: Label = $FPSLabel
@onready var life_indicator: TextureRect = $LifeIndicator


func _ready() -> void:
	Events.add_listener(LifeChangedEvent, _on_life_changed)
	_load_life_texture()
	_update_life_indicator(EffectManager.has_effect("has_life"))


func _load_life_texture() -> void:
	if life_indicator == null:
		return
	# Load the life orb texture
	var life_orb_data: Resource = load("res://resources/orbs/life_orb.tres")
	if life_orb_data != null and life_orb_data is OrbData:
		life_indicator.texture = life_orb_data.texture


func _process(_delta: float) -> void:
	if fps_label != null:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func _on_life_changed(event: LifeChangedEvent) -> void:
	_update_life_indicator(event.has_life())


func _update_life_indicator(has_life: bool) -> void:
	if life_indicator != null:
		life_indicator.visible = has_life
		if has_life:
			_start_life_pulse()
		else:
			_stop_life_pulse()


func _start_life_pulse() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(life_indicator, "modulate:a", 0.5, 0.5)
	tween.tween_property(life_indicator, "modulate:a", 1.0, 0.5)


func _stop_life_pulse() -> void:
	if life_indicator != null:
		life_indicator.modulate.a = 1.0
