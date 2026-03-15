extends Control
## Bonus Meter UI - Displays the vertical bonus meter with tier indicators.
## Polls ComboManager every frame for smooth drain animation.

#region Constants
const METER_HEIGHT: int = 600
const METER_WIDTH: int = 60
#endregion

#region Node References
@onready var meter_bar: TextureProgressBar = $VBoxContainer/MeterBar
@onready var tier_labels_container: VBoxContainer = $VBoxContainer/TierLabels
#endregion

#region Configuration
## Dimmed color for inactive tiers
const INACTIVE_COLOR: Color = Color(0.4, 0.4, 0.4, 1.0)
#endregion

#region Private State
var _tier_labels: Array[Label] = []
var _last_tier: int = -1
#endregion

#region Lifecycle
func _ready() -> void:
	_setup_meter_bar()
	_setup_tier_labels()
	_connect_events()
	_update_display()


func _process(_delta: float) -> void:
	# Poll every frame for smooth drain animation
	_update_display()
#endregion

#region Setup
func _setup_meter_bar() -> void:
	if meter_bar == null:
		return

	# Configure TextureProgressBar for vertical fill from bottom to top
	meter_bar.min_value = 0.0
	meter_bar.max_value = ComboManager.MAX_METER_VALUE
	meter_bar.value = 0.0
	meter_bar.fill_mode = TextureProgressBar.FILL_BOTTOM_TO_TOP

	# Create a simple white texture for the fill (will be tinted by modulate)
	var fill_image := Image.create(METER_WIDTH, METER_HEIGHT, false, Image.FORMAT_RGBA8)
	fill_image.fill(Color.WHITE)
	var fill_texture := ImageTexture.create_from_image(fill_image)
	meter_bar.texture_progress = fill_texture

	# Create background texture (dark gray)
	var bg_image := Image.create(METER_WIDTH, METER_HEIGHT, false, Image.FORMAT_RGBA8)
	bg_image.fill(Color(0.2, 0.2, 0.2, 1.0))
	var bg_texture := ImageTexture.create_from_image(bg_image)
	meter_bar.texture_under = bg_texture


func _setup_tier_labels() -> void:
	if tier_labels_container == null:
		return

	# Get all tier labels (should be 7, from top to bottom: tier 6 to tier 0)
	for child in tier_labels_container.get_children():
		if child is Label:
			_tier_labels.append(child)

	# Reverse so index matches tier (tier_labels[0] = tier 0)
	_tier_labels.reverse()


func _connect_events() -> void:
	# Listen for tier changes for sound effects / particles (optional)
	Events.add_listener(TierChangedEvent, _on_tier_changed)
	Events.add_listener(ComboResetEvent, _on_combo_reset)
#endregion

#region Display Updates
func _update_display() -> void:
	_update_meter_value()
	_update_tier_highlight()


func _update_meter_value() -> void:
	if meter_bar == null:
		return

	var meter_value: float = ComboManager.get_meter_value()
	meter_bar.value = meter_value


func _update_tier_highlight() -> void:
	var current_tier: int = ComboManager.get_current_tier()

	# Skip if tier hasn't changed
	if current_tier == _last_tier:
		return

	_last_tier = current_tier

	# Update meter bar color using tint
	if meter_bar != null:
		var tier_color: Color = ComboManager.TIER_COLORS[current_tier]
		meter_bar.tint_progress = tier_color

	# Update tier label highlights
	for i: int in range(_tier_labels.size()):
		var label: Label = _tier_labels[i]
		if i <= current_tier:
			# Active tier or below - use tier color
			label.add_theme_color_override("font_color", ComboManager.TIER_COLORS[i])
			label.modulate.a = 1.0
		else:
			# Inactive tier above current
			label.add_theme_color_override("font_color", INACTIVE_COLOR)
			label.modulate.a = 0.6
#endregion

#region Event Handlers
func _on_tier_changed(_event: TierChangedEvent) -> void:
	# Tier changed - could play sound or particles here
	# The display update happens in _process via polling
	pass


func _on_combo_reset(_event: ComboResetEvent) -> void:
	# Combo reset - update display immediately
	_update_display()
#endregion

#region Public API
## Forces an immediate display update (useful after game over)
func refresh() -> void:
	_last_tier = -1  # Force tier highlight update
	_update_display()
#endregion
