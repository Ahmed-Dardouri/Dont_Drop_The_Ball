extends Control
## Bonus Meter UI - Displays the vertical bonus meter with tier indicators.
## Polls ComboManager every frame for smooth drain animation.

#region Node References
@onready var meter_bar: ProgressBar = $VBoxContainer/MeterBar
@onready var tier_labels_container: VBoxContainer = $VBoxContainer/TierLabels
#endregion

#region Configuration
## Colors for each tier (0-6)
const TIER_COLORS: Array[Color] = [
	Color.WHITE,       # Tier 0: +1
	Color.LIGHT_BLUE,  # Tier 1: +2
	Color.CYAN,        # Tier 2: +5
	Color.LIME,        # Tier 3: +10
	Color.YELLOW,      # Tier 4: +20
	Color.ORANGE,      # Tier 5: +50
	Color.GOLD,        # Tier 6: +100
]

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

	# Configure progress bar
	meter_bar.min_value = 0.0
	meter_bar.max_value = ComboManager.MAX_METER_VALUE
	meter_bar.value = 0.0
	meter_bar.show_percentage = false


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

	# Update meter bar color
	if meter_bar != null:
		var tier_color: Color = TIER_COLORS[current_tier]
		var style_box: StyleBoxFlat = StyleBoxFlat.new()
		style_box.bg_color = tier_color
		meter_bar.add_theme_stylebox_override("fill", style_box)

	# Update tier label highlights
	for i: int in range(_tier_labels.size()):
		var label: Label = _tier_labels[i]
		if i <= current_tier:
			# Active tier or below - use tier color
			label.add_theme_color_override("font_color", TIER_COLORS[i])
			label.modulate.a = 1.0
		else:
			# Inactive tier above current
			label.add_theme_color_override("font_color", INACTIVE_COLOR)
			label.modulate.a = 0.6
#endregion

#region Event Handlers
func _on_tier_changed(event: TierChangedEvent) -> void:
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
