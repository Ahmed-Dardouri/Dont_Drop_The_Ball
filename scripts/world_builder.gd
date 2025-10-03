extends Node2D

var _current_scene : Enums.WorldScene = Enums.WorldScene.GAME
var _pause_screen_to_consume : bool = true

@onready var game_over_screen: CanvasLayer = $game_over_screen
@onready var pause_screen: CanvasLayer = $pause_screen
@onready var hud: CanvasLayer = $HUD



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_events()
	WorldBuiltEvent.invoke()
	SoundEnableEvent.invoke(Enums.SoundType.MUSIC, Enums.SoundCmd.PLAY)
	SoundPlayEvent.invoke(Enums.SoundType.MUSIC, Enums.Sounds.LOFI_BG_MUSIC)
	switch_scene(Enums.WorldScene.GAME)
	GameSaveMngr.load_game()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && _current_scene == Enums.WorldScene.GAME && _pause_screen_to_consume:
		PauseScreenEvent.invoke()


func load_world():
	SoundPlayEvent.invoke(Enums.SoundType.MUSIC, Enums.Sounds.LOFI_BG_MUSIC)
	hud.visible = true

func unload_world():
	hud.visible = false
	SoundEnableEvent.invoke(Enums.SoundType.MUSIC, Enums.SoundCmd.STOP)
	
func switch_scene(scene: Enums.WorldScene):
	_current_scene = scene
	hide_scenes()
	match _current_scene:
		Enums.WorldScene.GAME:
			PauseEvent.invoke(false)
		Enums.WorldScene.GAME_OVER_SCREEN:
			game_over_screen.visible = true
		Enums.WorldScene.PAUSE_SCREEN:
			pause_screen.visible = true

func hide_scenes():
	game_over_screen.visible = false
	pause_screen.visible = false

func world_button_handler(event: WorldButtonEvent):
	match  event._type:
		Enums.WorldButtonType.MAIN_MENU:
			main_menu_button_handle()
		Enums.WorldButtonType.BACK:
			back_button_handle()
		Enums.WorldButtonType.REPLAY:
			replay_button_handle()

func _add_events():
	Events.add_listener(WorldButtonEvent, world_button_handler)
	Events.add_listener(PauseScreenEvent, pause_screen_event_handle)
	
func main_menu_button_handle():
	SoundEnableEvent.invoke(Enums.SoundType.MUSIC, Enums.SoundCmd.STOP)
	switch_scene(Enums.WorldScene.GAME)
	PauseEvent.invoke(true)
	ButtonEvent.invoke(Enums.MainButtonType.BACK)
	
func back_button_handle():
	SoundEnableEvent.invoke(Enums.SoundType.MUSIC, Enums.SoundCmd.RESUME)
	match _current_scene:
		Enums.WorldScene.GAME:
			switch_scene(Enums.WorldScene.GAME)
		Enums.WorldScene.GAME_OVER_SCREEN:
			switch_scene(Enums.WorldScene.GAME)
		Enums.WorldScene.PAUSE_SCREEN:
			
			#wait for _input to run
			await Engine.get_main_loop().process_frame
			await Engine.get_main_loop().process_frame
			
			_pause_screen_to_consume = true
			switch_scene(Enums.WorldScene.GAME)
			
func replay_button_handle():
	switch_scene(Enums.WorldScene.GAME)
	ReplayEvent.invoke()

func pause_screen_event_handle(event: PauseScreenEvent):
	_pause_screen_to_consume = false
	SoundEnableEvent.invoke(Enums.SoundType.MUSIC, Enums.SoundCmd.PAUSE)
	switch_scene(Enums.WorldScene.PAUSE_SCREEN)
	PauseEvent.invoke(true)
