extends CanvasLayer
## AugmentChoiceUI - Displays 3 augment cards for player selection.
## Appears when an augment orb is collected.
## Supports keyboard navigation (arrows + jump) and mouse/touch click.

#region Signals

signal augment_selected(augment: Resource)

#endregion

#region Configuration

## Card size settings (adjustable)
const CARD_WIDTH: int = 320
const CARD_HEIGHT: int = 450

## Background sprite paths by rarity
const BG_PATH_COMMON: String = "res://sprites/common_bg.png"
const BG_PATH_RARE: String = "res://sprites/rare_bg.png"
const BG_PATH_MYTHICAL: String = "res://sprites/mythical_bg.png"
const BG_PATH_HIGHLIGHT: String = "res://sprites/caed_overlay.png"

#endregion

#region Private State

var _choices: Array = []  # Array of AugmentData resources
var _cards: Array[Dictionary] = []  # Array of {panel: Control, highlight: TextureRect}
var _is_active: bool = false
var _selected_index: int = 1  # Default to middle card

## Preloaded textures
var _bg_common: Texture2D
var _bg_rare: Texture2D
var _bg_mythical: Texture2D
var _bg_highlight: Texture2D

#endregion

#region Node References

@onready var _card_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/CardContainer
@onready var _background: ColorRect = $Background

#endregion

#region Lifecycle

func _ready() -> void:
	visible = false
	# Preload textures
	_preload_textures()
	# Process even when game is paused (process_mode = 3 in scene)
	Events.add_listener(AugmentSelectionStartedEvent, _on_selection_started)


func _preload_textures() -> void:
	_bg_common = load(BG_PATH_COMMON)
	_bg_rare = load(BG_PATH_RARE)
	_bg_mythical = load(BG_PATH_MYTHICAL)
	_bg_highlight = load(BG_PATH_HIGHLIGHT)


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
		var card_data: Dictionary = _create_card(augment, i)
		_card_container.add_child(card_data.panel)
		_cards.append(card_data)

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

func _create_card(augment: Resource, index: int) -> Dictionary:
	var augment_data: AugmentData = augment as AugmentData

	# Root container for the card
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(_on_card_gui_input.bind(index))

	# Transparent style for the panel (background handled by TextureRect)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)  # Transparent
	panel.add_theme_stylebox_override("panel", style)

	# Background texture based on rarity
	var bg_texture := TextureRect.new()
	bg_texture.name = "Background"
	bg_texture.texture = _get_rarity_bg_texture(augment_data.rarity)
	bg_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	bg_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(bg_texture)

	# Highlight overlay (hidden by default)
	var highlight := TextureRect.new()
	highlight.name = "Highlight"
	highlight.texture = _bg_highlight
	highlight.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	highlight.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	highlight.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	highlight.visible = false
	panel.add_child(highlight)

	# Content container
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(vbox)

	# Add padding inside the card
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)

	# Icon (loaded from sprite if available)
	var icon_texture := _get_icon_texture(augment_data.icon_key)
	if icon_texture != null:
		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(140, 140)
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = icon_texture
		vbox.add_child(icon_rect)
	else:
		# Spacer if no icon available
		var icon_spacer := Control.new()
		icon_spacer.custom_minimum_size = Vector2(140, 140)
		vbox.add_child(icon_spacer)

	# Spacer between icon and text
	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer1)

	# Name label
	var name_label := Label.new()
	name_label.text = augment_data.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
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
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	vbox.add_child(desc_label)

	return {"panel": panel, "highlight": highlight}


## Get background texture based on rarity
func _get_rarity_bg_texture(rarity: int) -> Texture2D:
	match rarity:
		Enums.AugmentRarity.MYTHICAL:
			return _bg_mythical
		Enums.AugmentRarity.RARE:
			return _bg_rare
		_:  # COMMON
			return _bg_common


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
	for card_data: Dictionary in _cards:
		card_data.panel.queue_free()
	_cards.clear()


func _select_card(index: int) -> void:
	if index < 0 or index >= _cards.size():
		return
	_selected_index = index
	_update_card_highlights()


func _update_card_highlights() -> void:
	for i: int in range(_cards.size()):
		var card_data: Dictionary = _cards[i]
		var highlight: TextureRect = card_data.highlight
		highlight.visible = (i == _selected_index)


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
