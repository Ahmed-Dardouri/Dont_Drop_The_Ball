extends CanvasLayer
## AugmentChoiceUI - Displays 3 augment cards for player selection.
## Appears when an augment orb is collected.
## Supports keyboard navigation (arrows + jump) and mouse/touch click.

#region Signals

signal augment_selected(augment: Resource)

#endregion

#region Private State

var _choices: Array = []  # Array of AugmentData resources
var _cards: Array[Control] = []
var _is_active: bool = false
var _selected_index: int = 1  # Default to middle card

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


func _input(event: InputEvent) -> void:
	if not _is_active:
		return

	# Keyboard navigation
	if event.is_action_pressed("Left"):
		_select_card(_selected_index - 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Right"):
		_select_card(_selected_index + 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Jump"):
		_confirm_selection()
		get_viewport().set_input_as_handled()

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

	# Default selection to middle card
	_selected_index = clamp(1, 0, _cards.size() - 1)
	_update_card_highlights()

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
	var augment_data: AugmentData = augment as AugmentData
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 450)  # Bigger cards
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_card_gui_input.bind(index))

	# Style the panel with rarity-based background
	var style := StyleBoxFlat.new()
	style.bg_color = _get_rarity_bg_color(augment_data.rarity)
	style.border_color = Color(0.5, 0.5, 0.7)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Add padding inside the card
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)

	# Icon placeholder (shows a colored rect based on icon_key)
	var icon_container := PanelContainer.new()
	icon_container.custom_minimum_size = Vector2(140, 140)  # Bigger icon
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = _get_icon_key_color(augment_data.icon_key)
	icon_style.set_corner_radius_all(8)
	icon_container.add_theme_stylebox_override("panel", icon_style)
	vbox.add_child(icon_container)

	# Try to load icon texture based on icon_key
	var icon_texture := _get_icon_texture(augment_data.icon_key)
	if icon_texture != null:
		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(140, 140)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = icon_texture
		icon_container.add_child(icon_rect)

	# Spacer between icon and text
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer1)

	# Name label
	var name_label := Label.new()
	name_label.text = augment_data.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)  # Bigger text
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)

	# Spacer between name and description
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer2)

	# Description label
	var desc_label := Label.new()
	desc_label.text = augment_data.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 18)  # Bigger text
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	vbox.add_child(desc_label)

	return panel


## Get background color based on rarity
func _get_rarity_bg_color(rarity: int) -> Color:
	match rarity:
		Enums.AugmentRarity.MYTHICAL:
			return Color(0.3, 0.1, 0.3, 0.95)  # Purple-ish
		Enums.AugmentRarity.RARE:
			return Color(0.1, 0.2, 0.4, 0.95)  # Blue-ish
		_:  # COMMON
			return Color(0.15, 0.15, 0.25, 0.95)  # Gray-ish


## Get icon placeholder color based on icon_key
func _get_icon_key_color(icon_key: String) -> Color:
	match icon_key:
		"score":
			return Color(1.0, 0.84, 0.0)  # Gold
		"burst":
			return Color(1.0, 0.4, 0.1)  # Orange
		"line":
			return Color(0.3, 0.7, 1.0)  # Cyan
		"vortex":
			return Color(0.6, 0.3, 0.9)  # Purple
		"life":
			return Color(1.0, 0.3, 0.4)  # Pink/Red
		"spawn":
			return Color(0.3, 1.0, 0.5)  # Green
		"meter":
			return Color(0.0, 0.8, 0.8)  # Teal
		"slowdown":
			return Color(0.5, 0.7, 1.0)  # Light blue
		_:
			return Color(0.3, 0.3, 0.5)  # Default gray


## Try to load icon texture based on icon_key
func _get_icon_texture(icon_key: String) -> Texture2D:
	var path := "res://sprites/augment_icons/%s.png" % icon_key
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _clear_cards() -> void:
	for card: Control in _cards:
		card.queue_free()
	_cards.clear()


func _select_card(index: int) -> void:
	if index < 0 or index >= _cards.size():
		return
	_selected_index = index
	_update_card_highlights()


func _update_card_highlights() -> void:
	for i: int in range(_cards.size()):
		var card: Control = _cards[i]
		var style: StyleBoxFlat = card.get_theme_stylebox("panel")
		if style:
			if i == _selected_index:
				style.border_color = Color(1.0, 0.8, 0.2)  # Gold
				style.set_border_width_all(6)
			else:
				style.border_color = Color(0.5, 0.5, 0.7)
				style.set_border_width_all(3)


func _on_card_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_card(index)
		_confirm_selection()
	elif event is InputEventScreenTouch and event.pressed:
		_select_card(index)
		_confirm_selection()


func _confirm_selection() -> void:
	if _selected_index < 0 or _selected_index >= _choices.size():
		return

	var chosen_augment: Resource = _choices[_selected_index]
	augment_selected.emit(chosen_augment)
	AugmentChosenEvent.invoke(chosen_augment)

	# Play card select sound
	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.CARD_SELECT)

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
