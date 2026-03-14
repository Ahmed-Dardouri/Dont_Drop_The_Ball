extends Node2D
class_name GenericOrb
## Data-driven orb that uses OrbData resources for configuration.
## All orb types are now defined via OrbData .tres files with behaviors.

#region OrbData Support

@onready var data_orb_area: Area2D = $DataOrbArea
@onready var data_orb_collision: CollisionShape2D = $DataOrbArea/CollisionShape2D

var _orb_data: OrbData = null
var _visual_sprite: Sprite2D = null
var _half_solid_body: StaticBody2D = null
var _half_solid_collision: CollisionPolygon2D = null
var _collision_setup_pending: bool = false

#endregion

#region Spawn Animation State

var _spawn_time_elapsed: float = 0.0
var _spawn_complete: bool = false

#endregion

#region Lifespan State

var _lifespan_time_elapsed: float = 0.0

#endregion


func _ready() -> void:
	# Handle deferred collision setup
	if _orb_data != null and _collision_setup_pending:
		_setup_orb_data_collision()
		_collision_setup_pending = false


func _process(delta: float) -> void:
	if _orb_data == null:
		return

	# Handle spawn animation
	if not _spawn_complete:
		_orb_data_spawn_animation(delta)
		return

	# Track lifespan and despawn when expired
	_lifespan_time_elapsed += delta
	if _lifespan_time_elapsed >= _orb_data.lifespan:
		_disable_collision()
		queue_free()
		return

	# Process behaviors that need per-frame updates
	for behavior: OrbBehavior in _orb_data.behaviors:
		behavior.process(self, delta)


#region OrbData Configuration

## Sets the OrbData for this orb, configuring collision and visuals.
func set_orb_data(orb_data: OrbData) -> void:
	_orb_data = orb_data

	# Create visual sprite from OrbData texture
	if orb_data.texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = orb_data.texture
		_visual_sprite.scale = orb_data.scale
		_visual_sprite.modulate.a = 0.0  # Start invisible for spawn animation
		add_child(_visual_sprite)

	# Handle half-solid orb setup
	if orb_data.is_half_solid:
		_setup_half_solid(orb_data)

	# Defer collision setup if @onready variables aren't initialized yet
	if data_orb_collision == null or data_orb_area == null:
		_collision_setup_pending = true
	else:
		_setup_orb_data_collision()

	# Add to "orbs" group for chain collection
	add_to_group("orbs")


## Sets up collision for OrbData path.
func _setup_orb_data_collision() -> void:
	if _orb_data == null:
		return

	# Set collision layers: area is on layer 2, detects bodies on layer 1
	data_orb_area.collision_layer = 2
	data_orb_area.collision_mask = 1

	# Disable collision during spawn animation
	data_orb_area.monitoring = false
	data_orb_area.monitorable = false

	if _orb_data.is_half_solid:
		# For half-solid orbs, use a semi-circle polygon for BOTTOM half (collectible)
		var collision_poly := CollisionPolygon2D.new()
		var radius: float = _orb_data.collision_radius
		var points: PackedVector2Array = []
		var segments: int = 16

		# BOTTOM half: from right (0°) through bottom (180°) to left
		for i in range(segments + 1):
			var angle: float = PI * i / segments  # From 0° to 180° (bottom half)
			var x: float = cos(angle) * radius
			var y: float = sin(angle) * radius
			points.append(Vector2(x, y))

		# Close the polygon with a flat line at the middle (y=0)
		points.append(Vector2(-radius, 0))
		points.append(Vector2(radius, 0))

		collision_poly.polygon = points
		collision_poly.position = data_orb_collision.position
		data_orb_collision.queue_free()
		data_orb_area.add_child(collision_poly)
	else:
		# Regular orb: use full circle
		var shape := CircleShape2D.new()
		shape.radius = _orb_data.collision_radius
		data_orb_collision.shape = shape

	if not data_orb_area.body_entered.is_connected(_on_data_orb_area_body_entered):
		data_orb_area.body_entered.connect(_on_data_orb_area_body_entered)


## Sets up half-solid orb components (static body for TOP half).
## Uses a single sprite centered at origin with both halves.
func _setup_half_solid(orb_data: OrbData) -> void:
	# Sprite stays centered at origin (single sprite with both halves)
	if _visual_sprite != null:
		_visual_sprite.position = Vector2.ZERO

	# Create the static body for the solid platform (TOP half only)
	_half_solid_body = StaticBody2D.new()

	# Add bouncy physics material for smooth bouncing
	var physics_mat := PhysicsMaterial.new()
	physics_mat.bounce = 0.3
	physics_mat.friction = 0.01  # No friction to prevent sticking
	_half_solid_body.physics_material_override = physics_mat

	_half_solid_collision = CollisionPolygon2D.new()

	# Create a semi-circle polygon for the TOP half (platform)
	var radius: float = orb_data.collision_radius
	var points: PackedVector2Array = []
	var segments: int = 16

	# TOP half: from left (180°) through top (270°) to right (0°/360°)
	for i in range(segments + 1):
		var angle: float = PI + (PI * i / segments)  # From 180° to 360° (top half)
		var x: float = cos(angle) * radius
		var y: float = sin(angle) * radius
		points.append(Vector2(x, y))

	# Close the polygon with a flat line at the middle (y=0)
	points.append(Vector2(radius, 0))
	points.append(Vector2(-radius, 0))

	_half_solid_collision.polygon = points
	_half_solid_collision.disabled = true  # Disabled during spawn animation
	_half_solid_collision.one_way_collision = true  # Only collide from above
	_half_solid_body.add_child(_half_solid_collision)
	_half_solid_body.add_to_group("half_solid")
	add_child(_half_solid_body)


#endregion

#region Getters

## Returns the OrbData for this orb.
func get_orb_data() -> OrbData:
	return _orb_data


## Returns the collision shape.
func get_collision_shape() -> CollisionShape2D:
	return data_orb_collision


## Returns the DataOrbArea for this orb.
func get_data_orb_area() -> Area2D:
	return data_orb_area


## Returns the visual sprite.
func get_visual_sprite() -> Sprite2D:
	return _visual_sprite


## Returns the spawn animation duration from OrbData.
func get_spawn_animation_duration() -> float:
	if _orb_data != null:
		return _orb_data.spawn_animation_duration
	return 0.0

#endregion

#region Spawn Animation

## Handles spawn animation - fades in the visual sprite.
func _orb_data_spawn_animation(delta: float) -> void:
	if _orb_data == null or _visual_sprite == null:
		_spawn_complete = true
		_enable_collision()
		return

	var duration: float = _orb_data.spawn_animation_duration
	if duration <= 0.0:
		_spawn_complete = true
		_visual_sprite.modulate.a = 1.0
		_enable_collision()
		return

	_spawn_time_elapsed += delta
	var progress: float = min(_spawn_time_elapsed / duration, 1.0)

	_visual_sprite.modulate.a = progress

	# Notify behaviors of spawn progress
	for behavior: OrbBehavior in _orb_data.behaviors:
		behavior.on_spawn(self, progress)

	if progress >= 1.0:
		_spawn_complete = true
		_enable_collision()


## Enables collision after spawn animation completes.
func _enable_collision() -> void:
	if data_orb_area != null:
		data_orb_area.monitoring = true
		data_orb_area.monitorable = true
	if _half_solid_collision != null:
		_half_solid_collision.disabled = false


## Disables all collision immediately (called before despawn).
func _disable_collision() -> void:
	if data_orb_area != null:
		data_orb_area.monitoring = false
		data_orb_area.monitorable = false
	if _half_solid_collision != null:
		_half_solid_collision.disabled = true

#endregion

#region Collection

## Handles ball collision.
func _on_data_orb_area_body_entered(body: Node2D) -> void:
	if _orb_data == null:
		return

	if body.is_in_group("ball"):
		# Skip collision if ball is in rescue mode
		if body.has_method("is_rescuing") and body.is_rescuing():
			return
		on_orb_collected()


## Called when orb is collected by the ball.
func on_orb_collected() -> void:
	if _orb_data == null:
		return

	# Disable collision immediately to prevent bounce-after-disappear
	_disable_collision()

	# Fire event for any listeners (UI, achievements, etc.)
	OrbCollectedEvent.invoke(_orb_data)

	# Execute behaviors
	var context := {"orb": self, "orb_data": _orb_data, "collector": null}
	for behavior: OrbBehavior in _orb_data.behaviors:
		behavior.execute(context)

	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
	queue_free()

#endregion
