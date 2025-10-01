extends Node2D

@onready var world_builder: Node2D = $world_builder
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var main_menu: Control = $main_menu

var _index : int = 0
var _scene_path := "res://scenes/world_builder.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_events() # keep first
	setup_game()





func replay_handler(event: ReplayEvent):
	_reload_world()
	PauseEvent.invoke(false)
	
func get_world_builder() -> Node2D:
	# print(get_children())
	var node = get_child(_index)
	return node


func _reload_world():
	# Load and instance a new copy
	var new_scene = load(_scene_path).instantiate()
	
	# get old scene
	var old_scene = get_world_builder()

	# Remove the old instance
	old_scene.queue_free()
	
	# wait for node to be removed
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	
	#add node to main
	add_child(new_scene)
	move_child(new_scene, _index)  # keep the same position in the tree

func handle_pause(event: PauseEvent):
	get_tree().paused = event._pause

func handle_buttons(event: ButtonEvent):
	match event._type:
		Enums.ButtonType.PLAY:
			play_button_handle()
		Enums.ButtonType.CONTROLS:
			pass
		Enums.ButtonType.BACK:
			pass
		Enums.ButtonType.EXIT:
			pass
		Enums.ButtonType.PAUSE:
			pass
		Enums.ButtonType.TUTORIAL:
			pass
		Enums.ButtonType.AUDIO:
			pass
		Enums.ButtonType.VIDEO:
			pass
		_:
			pass
			
			
func play_button_handle():
	print("play")
	get_world_builder().visible = true
	PauseEvent.invoke(false)
	phantom_camera_2d.priority = 0
	main_menu.visible = false #need a better state machine approach
	
func controls_button_handle():
	pass			

func back_button_handle():
	pass			

func exit_button_handle():
	pass			

func pause_button_handle():
	pass			

func tutorial_button_handle():
	pass			

func audio_button_handle():
	pass			
	
func video_button_handle():
	pass			
			
			

func setup_game():
	# pause game by default
	PauseEvent.invoke(true)


func add_events():
	Events.add_listener(ReplayEvent, replay_handler)
	Events.add_listener(PauseEvent, handle_pause)
	Events.add_listener(ButtonEvent, handle_buttons)
