extends Node2D

@onready var world_builder: Node2D = $world_builder

var _index : int = 0
var _scene_path := "res://scenes/world_builder.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(ReplayEvent, replay_handler)
	Events.add_listener(PauseEvent, handle_pause)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	

	add_child(new_scene)
	move_child(new_scene, _index)  # keep the same position in the tree

func handle_pause(event: PauseEvent):
	get_tree().paused = event._pause
