extends Control

@onready var music_h_slider: HSlider = $PanelContainer/VBoxContainer/MusicPanelContainer/MarginContainer/HBoxContainer/Music_HSlider
@onready var sfx_h_slider: HSlider = $PanelContainer/VBoxContainer/SfxPanelContainer/MarginContainer/HBoxContainer/Sfx_HSlider

const NO_SOUND_DB = -200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_events()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.BACK)


func _add_events():
	Events.add_listener(GameLoadEvent, game_load_handle)

func game_load_handle(event: GameLoadEvent):
	music_h_slider.value = event._saved_game.Music_volume
	sfx_h_slider.value = event._saved_game.Sfx_volume
	
	update_music()
	update_sfx()

func _on_music_h_slider_drag_ended(value_changed: bool) -> void:
	update_music()

func _on_sfx_h_slider_drag_ended(value_changed: bool) -> void:
	update_sfx()

func update_music():
	
	if music_h_slider.value <= music_h_slider.min_value:
		VolumeSetEvent.invoke(Enums.SoundType.MUSIC, NO_SOUND_DB)
	else:
		VolumeSetEvent.invoke(Enums.SoundType.MUSIC, music_h_slider.value)

func update_sfx():
	if sfx_h_slider.value <= sfx_h_slider.min_value:
		VolumeSetEvent.invoke(Enums.SoundType.SFX, NO_SOUND_DB)
	else:
		VolumeSetEvent.invoke(Enums.SoundType.SFX, sfx_h_slider.value)
