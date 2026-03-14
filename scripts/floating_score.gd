class_name FloatingScore extends Node2D
## Floating score label that shows base score and combo bonus.
## Floats up and fades out over time.

## Base score label (white/yellow)
@onready var base_label: Label = $BaseLabel
## Combo bonus label (gold/orange)
@onready var combo_label: Label = $ComboLabel

## How long the label floats (seconds)
@export var duration: float = 1.5
## Float speed (pixels per second)
@export var float_speed: float = 60.0
## Vertical offset between base and combo labels
@export var label_offset: float = 30.0

var _time_elapsed: float = 0.0
var _base_score: int = 0
var _combo_bonus: int = 0


func _ready() -> void:
	_time_elapsed = 0.0


func _process(delta: float) -> void:
	_time_elapsed += delta

	# Float upward
	position.y -= float_speed * delta

	# Fade out over time
	var alpha: float = 1.0 - (_time_elapsed / duration)
	if base_label != null:
		base_label.modulate.a = alpha
	if combo_label != null:
		combo_label.modulate.a = alpha

	# Remove when faded out
	if _time_elapsed >= duration:
		queue_free()


## Sets the scores to display.
## base_score: The normal orb score (white)
## combo_bonus: The combo bonus (gold/orange)
func set_scores(base_score: int, combo_bonus: int) -> void:
	_base_score = base_score
	_combo_bonus = combo_bonus

	if base_label != null:
		if base_score > 0:
			base_label.text = "+%d" % base_score
			base_label.show()
		else:
			base_label.hide()

	if combo_label != null:
		if combo_bonus > 0:
			combo_label.text = "+%d" % combo_bonus
			combo_label.show()
		else:
			combo_label.hide()


## Spawns a floating score at the given world position.
## Returns the spawned node.
static func spawn_at(parent: Node, world_pos: Vector2, base_score: int, combo_bonus: int) -> Node:
	var scene := preload("res://scenes/floating_score.tscn")
	var instance := scene.instantiate()
	instance.position = world_pos
	parent.add_child(instance)
	instance.set_scores(base_score, combo_bonus)
	return instance
