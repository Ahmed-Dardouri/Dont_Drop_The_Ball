extends Node2D

@onready var music_player: AudioStreamPlayer2D = $music_player
@onready var sfx_player: AudioStreamPlayer2D = $sfx_player

@export var sfx_list: Array[SoundEntry]
@export var music_list: Array[SoundEntry]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(SoundPlayEvent, sound_play_event_handler)
	Events.add_listener(GameOverEvent, handle_game_over)
	SoundPlayEvent.invoke_sound_play(Enums.SoundType.MUSIC, Enums.Sounds.LOFI_BG_MUSIC)

func play_sfx(stream: AudioStream) -> void:
	if stream != null:
		sfx_player.stream = stream
		sfx_player.play()

func play_music(stream: AudioStream) -> void:
	if stream != null:
		music_player.stream = stream
		music_player.stream_paused = false
		music_player.autoplay = true
		music_player.play()

func stop_music() -> void:
	music_player.stop()


func get_sfx(type: Enums.Sounds) -> AudioStream:
	var stream : AudioStream = null
	for i in sfx_list.size():
		if sfx_list[i].key == type:
			stream = sfx_list[i].audio
		
	return stream
	
func get_music(type: Enums.Sounds) -> AudioStream:
	var stream : AudioStream = null
	for i in music_list.size():
		if music_list[i].key == type:
			stream = music_list[i].audio
		
	return stream
	
func sound_play_event_handler(event: SoundPlayEvent):
	if event._type == Enums.SoundType.SFX:
		play_sfx(get_sfx(event._sound))
	elif event._type == Enums.SoundType.MUSIC:
		play_music(get_music(event._sound))
	
func handle_game_over(event: GameOverEvent):
	stop_music()
