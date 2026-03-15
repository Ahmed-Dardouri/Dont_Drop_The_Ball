class_name FloatingScore extends Node2D
## Floating score label that shows base score and combo bonus.
## Floats up and fades out over time.
## Colors match the bonus meter tier colors.

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

## Colors for each tier (0-6) - matches bonus_meter.gd
const TIER_COLORS: Array[Color] = [
	Color.WHITE,       # Tier 0: +1
	Color.LIGHT_BLUE,  # Tier 1: +2
	Color.CYAN,        # Tier 2: +5
	Color.LIME,        # Tier 3: +10
	Color.YELLOW,      # Tier 4: +20
	Color.ORANGE,      # Tier 5: +50
	Color.GOLD,        # Tier 6: +100
]

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


## Sets the scores to display with tier-based coloring.
## base_score: The normal orb score (always white)
## combo_bonus: The combo bonus (colored by tier)
## tier: Current combo tier (0-6) for bonus color selection
func set_scores(base_score: int, combo_bonus: int, tier: int = 0) -> void:
	_base_score = base_score
	_combo_bonus = combo_bonus

	# Base score is always white
	if base_label != null:
		if base_score > 0:
			base_label.text = "+%d" % base_score
			base_label.add_theme_color_override("font_color", Color.WHITE)
			base_label.show()
		else:
			base_label.hide()

	# Combo bonus is colored by tier
	if combo_label != null:
		if combo_bonus > 0:
			combo_label.text = "+%d" % combo_bonus
			var clamped_tier: int = clampi(tier, 0, TIER_COLORS.size() - 1)
			var tier_color: Color = TIER_COLORS[clamped_tier]
			combo_label.add_theme_color_override("font_color", tier_color)
			combo_label.show()
		else:
			combo_label.hide()


## Spawns a floating score at the given world position with tier coloring.
## Returns the spawned node.
static func spawn_at(parent: Node, world_pos: Vector2, base_score: int, combo_bonus: int, tier: int = 0) -> Node:
	if parent == null:
		return null
	var scene := preload("res://scenes/floating_score.tscn")
	var instance := scene.instantiate()
	instance.position = world_pos
	parent.add_child(instance)
	instance.set_scores(base_score, combo_bonus, tier)
	return instance
