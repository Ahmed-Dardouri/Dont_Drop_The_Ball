class_name Orb extends Node2D
## Base class for all orb types.
## Handles spawn animation, lifetime management, and collection behavior.

signal collected

## Definition containing orb properties (score, lifespan, etc.)
@export var definition: OrbDefinition

var _lifetime_timer: Timer
var _spawn_timer: Timer
var _is_active: bool = false
var _spawn_duration: float = 1.5


func _ready() -> void:
	add_to_group("orbs")

	if definition == null:
		push_error("Orb requires a definition")
		return

	_setup_spawn_animation()
	_setup_lifetime()


func _setup_spawn_animation() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.wait_time = _spawn_duration
	_spawn_timer.timeout.connect(_on_spawn_complete)
	add_child(_spawn_timer)
	_spawn_timer.start()

	modulate.a = 0.0


func _process(_delta: float) -> void:
	if not _is_active and _spawn_timer:
		var progress := 1.0 - (_spawn_timer.time_left / _spawn_duration)
		modulate.a = progress * 0.75


func _on_spawn_complete() -> void:
	_is_active = true
	modulate.a = 1.0


func _setup_lifetime() -> void:
	_lifetime_timer = Timer.new()
	_lifetime_timer.one_shot = true
	_lifetime_timer.wait_time = definition.lifespan_seconds
	_lifetime_timer.timeout.connect(queue_free)
	add_child(_lifetime_timer)
	_lifetime_timer.start()


## Collect this orb. Adds score, emits signal, and frees the node.
## Blocked when paused or during spawn animation.
func collect() -> void:
	if not _is_active or GameState.is_paused:
		return

	collected.emit()
	ScoreManager.add_score(definition.score_value)
	queue_free()


## Handle body collision. Override in subclasses for custom behavior.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		collect()
