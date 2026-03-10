extends Node2D
class_name GenericOrb

#region OrbData Collision Support (F1 Fix)

@onready var data_orb_area: Area2D = $DataOrbArea
@onready var data_orb_collision: CollisionShape2D = $DataOrbArea/CollisionShape2D

var _orb_data: OrbData = null
var _visual_sprite: Sprite2D = null
var _collision_setup_pending: bool = false  # Flag for deferred collision setup

#region Spawn Animation State (F2 Fix)

var _spawn_time_elapsed: float = 0.0
var _spawn_complete: bool = false

#endregion

#region Child Orbs (Old Path)

@onready var blue_orb: BlueOrb = $child_orbs/blue_orb
@onready var red_orb: RedOrb = $child_orbs/red_orb
@onready var half_solid_orb: HalfSolidOrb = $child_orbs/half_solid_orb

#endregion

@onready var child_orbs: Node2D = $child_orbs

@onready var timer: Timer = $Timer

var _child_orb : Node2D
@export var _props : OrbProps = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Handle deferred collision setup for OrbData path
	if _orb_data != null and _collision_setup_pending:
		_setup_orb_data_collision()
		_collision_setup_pending = false
	# Only initialize old path if we're not using OrbData
	else:
		update_orb()
		init_timer()
		disable_child_orb()

func _process(delta: float) -> void:
	# OrbData path
	if _orb_data != null:
		# Handle spawn animation for OrbData path
		if not _spawn_complete:
			_orb_data_spawn_animation(delta)
			return

		# Process behaviors that need per-frame updates
		for behavior: OrbBehavior in _orb_data.behaviors:
			behavior.process(self, delta)
		return

	# Old path: OrbProps spawn animation
	orb_spawn_animation()

#region OrbData Path Methods

## Sets the OrbData for this orb, configuring collision and visuals.
## This switches the orb to use the new data-driven path.
func set_orb_data(orb_data: OrbData) -> void:
	_orb_data = orb_data

	# Free child orbs - we don't need them for OrbData path
	if child_orbs != null:
		for child in child_orbs.get_children():
			child.queue_free()

	# Create visual sprite from OrbData texture
	if orb_data.texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = orb_data.texture
		_visual_sprite.scale = orb_data.scale
		_visual_sprite.modulate.a = 0.0  # Start invisible for spawn animation
		add_child(_visual_sprite)

	# Defer collision setup if @onready variables aren't initialized yet
	if data_orb_collision == null or data_orb_area == null:
		_collision_setup_pending = true
	else:
		_setup_orb_data_collision()

	# Add to "orbs" group for chain collection
	add_to_group("orbs")


## Sets up collision for OrbData path. Called from _ready() if deferred.
func _setup_orb_data_collision() -> void:
	if _orb_data == null:
		return

	# Configure collision for OrbData path
	var shape := CircleShape2D.new()
	shape.radius = _orb_data.collision_radius
	data_orb_collision.shape = shape
	data_orb_area.monitoring = true
	data_orb_area.monitorable = true

	# Connect collision signal
	if not data_orb_area.body_entered.is_connected(_on_data_orb_area_body_entered):
		data_orb_area.body_entered.connect(_on_data_orb_area_body_entered)


## Returns the OrbData for this orb, or null if using old path.
func get_orb_data() -> OrbData:
	return _orb_data


## Returns the collision shape for OrbData path.
func get_collision_shape() -> CollisionShape2D:
	return data_orb_collision


## Returns the DataOrbArea for this orb.
func get_data_orb_area() -> Area2D:
	return data_orb_area


## Returns the visual sprite for OrbData path.
func get_visual_sprite() -> Sprite2D:
	return _visual_sprite


## Returns the spawn animation duration from OrbData.
func get_spawn_animation_duration() -> float:
	if _orb_data != null:
		return _orb_data.spawn_animation_duration
	return 0.0


## Handles spawn animation for OrbData path.
## Fades in the visual sprite over the spawn duration.
func _orb_data_spawn_animation(delta: float) -> void:
	if _orb_data == null or _visual_sprite == null:
		_spawn_complete = true
		return

	var duration: float = _orb_data.spawn_animation_duration
	if duration <= 0.0:
		_spawn_complete = true
		_visual_sprite.modulate.a = 1.0
		return

	_spawn_time_elapsed += delta
	var progress: float = min(_spawn_time_elapsed / duration, 1.0)

	# Fade in from 0 to 1
	_visual_sprite.modulate.a = progress

	# Also notify behaviors of spawn progress
	for behavior: OrbBehavior in _orb_data.behaviors:
		behavior.on_spawn(self, progress)

	if progress >= 1.0:
		_spawn_complete = true


## Handles ball collision for OrbData path.
func _on_data_orb_area_body_entered(body: Node2D) -> void:
	if _orb_data == null:
		return  # Not an OrbData orb, ignore

	# Check if it's the ball
	if body.is_in_group("ball"):
		on_orb_collected()


## Called when orb is collected (OrbData path).
func on_orb_collected() -> void:
	if _orb_data == null:
		return

	# Execute behaviors
	var context := {"orb": self, "orb_data": _orb_data, "collector": null}
	for behavior: OrbBehavior in _orb_data.behaviors:
		behavior.execute(context)

	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
	queue_free()

#endregion

#region Old Path Methods

func converge_orb(type: Enums.OrbType):
	match type:
		Enums.OrbType.BLUE:
			_child_orb = blue_orb
		Enums.OrbType.RED:
			_child_orb = red_orb
		Enums.OrbType.HALF_SOLID:
			_child_orb = half_solid_orb
		_:
			_child_orb = null

	if child_orbs != null:
		for child in child_orbs.get_children():
			if child != _child_orb:
				child.queue_free()


func set_type(props :OrbProps):
	_props = props

func update_orb():
	if _props != null:
		converge_orb(_props.Type)

func set_child_opacity_to_timer():
	if _child_orb != null and timer != null:
		var value = float(float(timer.wait_time - timer.time_left)/timer.wait_time) * 0.75
		_child_orb.set_sprite_opacity(value)

func _on_timer_timeout() -> void:
	enable_child_orb()


func orb_spawn_animation():
	if timer != null and timer.time_left != 0:
		set_child_opacity_to_timer()

func disable_child_orb():
	if _child_orb != null:
		_child_orb.set_sprite_opacity(0)
		_child_orb.set_collision_enable(false)


func enable_child_orb():
	if _child_orb != null:
		_child_orb.set_sprite_opacity(1)
		_child_orb.set_collision_enable(true)

func init_timer():
	if timer != null:
		timer.one_shot = true
		timer.wait_time = 1.5
		timer.start()

#endregion
