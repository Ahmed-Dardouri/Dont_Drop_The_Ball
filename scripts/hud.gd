extends CanvasLayer

@onready var button_controls: Control = $button_controls
@onready var fps_label: Label = $FPSLabel
@onready var life_indicator: TextureRect = $LifeIndicator
@onready var vortex_indicator: TextureRect = $VortexIndicator


func _ready() -> void:
	Events.add_listener(LifeChangedEvent, _on_life_changed)
	Events.add_listener(VortexChangedEvent, _on_vortex_changed)
	_load_life_texture()
	_load_vortex_texture()
	_update_life_indicator(EffectManager.has_effect("has_life"))
	_update_vortex_indicator(_has_active_vortex())


func _load_life_texture() -> void:
	if life_indicator == null:
		return
	# Load the life orb texture
	var life_orb_data: Resource = load("res://resources/orbs/life_orb.tres")
	if life_orb_data != null and life_orb_data is OrbData:
		life_indicator.texture = life_orb_data.texture


func _load_vortex_texture() -> void:
	if vortex_indicator == null:
		return
	# Load the vortex orb texture
	var vortex_orb_data: Resource = load("res://resources/orbs/vortex_orb.tres")
	if vortex_orb_data != null and vortex_orb_data is OrbData:
		vortex_indicator.texture = vortex_orb_data.texture


func _process(_delta: float) -> void:
	if fps_label != null:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func _has_active_vortex() -> bool:
	return get_tree().get_nodes_in_group("vortex_effect").size() > 0


func _on_life_changed(event: LifeChangedEvent) -> void:
	_update_life_indicator(event.has_life())


func _on_vortex_changed(event: VortexChangedEvent) -> void:
	_update_vortex_indicator(event.has_vortex())


func _update_life_indicator(has_life: bool) -> void:
	if life_indicator != null:
		life_indicator.visible = has_life
		if has_life:
			_start_life_pulse()
		else:
			_stop_life_pulse()


func _update_vortex_indicator(has_vortex: bool) -> void:
	if vortex_indicator != null:
		vortex_indicator.visible = has_vortex
		if has_vortex:
			_start_vortex_pulse()
		else:
			_stop_vortex_pulse()


func _start_life_pulse() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(life_indicator, "modulate:a", 0.5, 0.5)
	tween.tween_property(life_indicator, "modulate:a", 1.0, 0.5)


func _stop_life_pulse() -> void:
	if life_indicator != null:
		life_indicator.modulate.a = 1.0


func _start_vortex_pulse() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(vortex_indicator, "modulate:a", 0.5, 0.5)
	tween.tween_property(vortex_indicator, "modulate:a", 1.0, 0.5)


func _stop_vortex_pulse() -> void:
	if vortex_indicator != null:
		vortex_indicator.modulate.a = 1.0
