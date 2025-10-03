extends Node2D

@onready var world_builder: Node2D = $world_builder
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var main_menu: Control = $main_menu
@onready var settings_menu: Control = $settings_menu


var _index : int = 0
var _scene_path := "res://scenes/world_builder.tscn"
var _current_scene : Enums.MainScene = Enums.MainScene.MAIN_MENU
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_events() # keep first
	setup_game()
	GameSaveMngr.load_game()





func replay_handler(event: ReplayEvent):
	_reload_world()
	PauseEvent.invoke(false)
	
func get_world_builder():
	world_builder = get_child(_index)


func _reload_world():
	# Load and instance a new copy
	var new_scene = load(_scene_path).instantiate()
	
	# get old scene
	get_world_builder()

	# Remove the old instance
	world_builder.queue_free()
	
	# wait for node to be removed
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	
	world_builder = new_scene
	
	#add node to main
	add_child(world_builder)
	move_child(world_builder, _index)  # keep the same position in the tree
	world_builder.load_world()
	
func handle_pause(event: PauseEvent):
	get_tree().paused = event._pause

func handle_buttons(event: ButtonEvent):
	
	phantom_camera_2d.priority = 5
	match event._type:
		Enums.MainButtonType.PLAY:
			play_button_handle()
		Enums.MainButtonType.SETTINGS:
			settngs_button_handle()
		Enums.MainButtonType.BACK:
			back_button_handle()
		Enums.MainButtonType.EXIT:
			exit_button_handle()
		_:
			pass
			
			
func play_button_handle():
	_reload_world()
	PauseEvent.invoke(false)
	phantom_camera_2d.priority = 0
	switch_scene(Enums.MainScene.WORLD_BUILDER)
	
func settngs_button_handle():
	switch_scene(Enums.MainScene.SETTINGS_MENU)
		
func back_button_handle():
	match _current_scene:
		Enums.MainScene.WORLD_BUILDER:
			PauseEvent.invoke(true)
			world_builder.unload_world()
			switch_scene(Enums.MainScene.MAIN_MENU)
		Enums.MainScene.SETTINGS_MENU:
			switch_scene(Enums.MainScene.MAIN_MENU)
		Enums.MainScene.MAIN_MENU:
			switch_scene(Enums.MainScene.MAIN_MENU)

func exit_button_handle():
	exit_game()




func setup_game():
	# pause game by default
	PauseEvent.invoke(true)
	switch_scene(_current_scene)


func add_events():
	Events.add_listener(ReplayEvent, replay_handler)
	Events.add_listener(PauseEvent, handle_pause)
	Events.add_listener(ButtonEvent, handle_buttons)
	

func switch_scene(scene: Enums.MainScene):
	_current_scene = scene
	hide_scenes()
	match _current_scene:
		Enums.MainScene.WORLD_BUILDER:
			world_builder.visible = true
		Enums.MainScene.MAIN_MENU:
			main_menu.visible = true
		Enums.MainScene.SETTINGS_MENU:
			settings_menu.visible = true
		
		
func hide_scenes():
	world_builder.visible = false
	main_menu.visible = false
	settings_menu.visible = false

func exit_game():
	get_tree().quit()
