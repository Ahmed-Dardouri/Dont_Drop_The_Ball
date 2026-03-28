extends CanvasLayer
## AugmentChoiceUI - Displays 3 augment cards for player selection.
## Appears when an augment orb is collected.

#region Signals

signal augment_selected(augment: Resource)

#endregion

#region Private State

var _choices: Array = []  # Array of AugmentData resources
var _cards: Array[Control] = []
var _is_active: bool = false

#endregion

#region Node References

@onready var _card_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/CardContainer
@onready var _title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var _background: ColorRect = $Background

#endregion

#region Lifecycle

func _ready() -> void:
	visible = false
	# Process even when game is paused (process_mode = 3 in scene)
	Events.add_listener(AugmentSelectionStartedEvent, _on_selection_started)

#endregion

#region Public API

## Show the augment selection UI with the given choices
func show_choices(choices: Array) -> void:
	_choices = choices
	_is_active = true
	visible = true

	# Clear existing cards
	_clear_cards()

	# Create new cards
	for i: int in range(_choices.size()):
		var augment: Resource = _choices[i]
		var card: Control = _create_card(augment, i)
		_card_container.add_child(card)
		_cards.append(card)

	# Pause the game
	PauseEvent.invoke(true)


## Hide the UI and resume the game
func hide_ui() -> void:
	_is_active = false
	visible = false
	_clear_cards()
	PauseEvent.invoke(false)

#endregion

#region Private Methods

func _create_card(augment: Resource, index: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 350)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	# Style the panel
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.25, 0.95)
	style.border_color = Color(0.5, 0.5, 0.7)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Icon placeholder (shows a colored rect if no texture)
	var icon_container := PanelContainer.new()
	icon_container.custom_minimum_size = Vector2(100, 100)
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(0.3, 0.3, 0.5)
	icon_style.set_corner_radius_all(8)
	icon_container.add_theme_stylebox_override("panel", icon_style)
	vbox.add_child(icon_container)

	# Icon texture if available
	if augment.icon != null:
		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(100, 100)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = augment.icon
		icon_container.add_child(icon_rect)

	# Name label
	var name_label := Label.new()
	name_label.text = augment.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)

	# Description label
	var desc_label := Label.new()
	desc_label.text = augment.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	vbox.add_child(desc_label)

	# Spacer
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# Select button
	var select_btn := Button.new()
	select_btn.text = "Select"
	select_btn.add_theme_font_size_override("font_size", 20)
	vbox.add_child(select_btn)

	# Connect button press
	select_btn.pressed.connect(_on_card_selected.bind(index))

	# Hover effect
	panel.mouse_entered.connect(_on_card_hover.bind(panel, true))
	panel.mouse_exited.connect(_on_card_hover.bind(panel, false))

	return panel


func _clear_cards() -> void:
	for card: Control in _cards:
		card.queue_free()
	_cards.clear()


func _on_card_hover(card: Control, is_hovering: bool) -> void:
	var style: StyleBoxFlat = card.get_theme_stylebox("panel")
	if style:
		if is_hovering:
			style.border_color = Color(1.0, 0.8, 0.2)
			style.set_border_width_all(5)
		else:
			style.border_color = Color(0.5, 0.5, 0.7)
			style.set_border_width_all(3)


func _on_card_selected(index: int) -> void:
	if index < 0 or index >= _choices.size():
		return

	var chosen_augment: Resource = _choices[index]
	augment_selected.emit(chosen_augment)
	AugmentChosenEvent.invoke(chosen_augment)
	hide_ui()

	# Trigger rescue to reset ball/player to safe state
	_trigger_augment_rescue()


func _trigger_augment_rescue() -> void:
	var balls := get_tree().get_nodes_in_group("ball")
	if balls.is_empty():
		return

	var ball: Node = balls[0]
	if ball.has_method("start_rescue_movement"):
		var augment_texture: Texture2D = load("res://resources/orbs/augment_orb.tres").texture
		ball.start_rescue_movement(augment_texture)


#endregion

#region Event Handlers

func _on_selection_started(event: AugmentSelectionStartedEvent) -> void:
	show_choices(event._choices)

#endregion
