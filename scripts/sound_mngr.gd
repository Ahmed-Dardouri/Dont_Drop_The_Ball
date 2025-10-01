extends Node2D

@onready var music_player: AudioStreamPlayer2D = $music_player
@onready var sfx_player: AudioStreamPlayer2D = $sfx_player

@export var sfx_list: Array[SoundEntry]
@export var music_list: Array[SoundEntry]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_events()
	
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

func stop_sfx() -> void:
	sfx_player.stop()
	
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
	
func handle_world_built(event: WorldBuiltEvent):
	play_music(get_music(Enums.Sounds.LOFI_BG_MUSIC))
	
func handle_game_over(event: GameOverEvent):
	stop_music()

func volume_set_handle(event: VolumeSetEvent):
	var saved_game := GameSaveMngr.get_saved_game()
	if event._type == Enums.SoundType.MUSIC:
		saved_game.Music_volume = event._volume
		music_player.volume_db = event._volume
		
	elif event._type == Enums.SoundType.SFX:
		saved_game.Sfx_volume = event._volume
		sfx_player.volume_db = event._volume
		
	GameSaveMngr.set_saved_game(saved_game)
	print(saved_game.Music_volume )
	GameSaveMngr.save_game()
	
func sound_enable_handle(event: SoundEnableEvent):
	
	if event._enable == false:
		if event._type == Enums.SoundType.MUSIC:	
			stop_music()
		elif event._type == Enums.SoundType.SFX:
			stop_sfx()
	
func add_events():
	Events.add_listener(VolumeSetEvent, volume_set_handle)
	Events.add_listener(SoundPlayEvent, sound_play_event_handler)
	Events.add_listener(GameOverEvent, handle_game_over)
	Events.add_listener(WorldBuiltEvent, handle_world_built)
	Events.add_listener(SoundEnableEvent, sound_enable_handle)
