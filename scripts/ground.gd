extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add ground_static child to "ground" group
	var ground_static = get_node_or_null("ground_static")
	if ground_static:
		ground_static.add_to_group("ground")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
