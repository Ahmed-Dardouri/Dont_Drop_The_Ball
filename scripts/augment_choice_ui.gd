extends CanvasLayer
## AugmentChoiceUI - Displays 3 augment cards for player selection.
## Appears when an augment orb is collected.
## Supports keyboard navigation (arrows + jump) and mouse/touch click.
##
## All card nodes are created and added_child'd in _ready() so they
## exist before the game is ever paused. show_choices() only updates
## their content and position. Textures use preload() for reliable
## export on all platforms.

#region Signals

signal augment_selected(augment: Resource)

#endregion

#region Configuration

const CARD_COUNT: int = 3

# Preloaded textures — guaranteed at compile time, reliable on export
const BG_COMMON: Texture2D = preload("res://sprites/common_bg.png")
const BG_RARE: Texture2D = preload("res://sprites/rare_bg.png")
const BG_MYTHICAL: Texture2D = preload("res://sprites/mythical_bg.png")
const BG_HIGHLIGHT: Texture2D = preload("res://sprites/caed_overlay.png")
const BOLD_FONT: FontFile = preload("res://addons/phantom_camera/fonts/Nunito-Black.ttf")
const AUGMENT_ORB_TEXTURE: Texture2D = preload("res://sprites/augment_orb.png")

# Icon preloads — no dynamic load() paths
const ICONS: Dictionary = {
	"burst": preload("res://sprites/augment_icons/burst.png"),
	"life": preload("res://sprites/augment_icons/life.png"),
	"line": preload("res://sprites/augment_icons/line.png"),
	"meter": preload("res://sprites/augment_icons/meter.png"),
	"orb": preload("res://sprites/augment_icons/orb.png"),
	"score": preload("res://sprites/augment_icons/score.png"),
	"spawn": preload("res://sprites/augment_icons/spawn.png"),
	"vortex": preload("res://sprites/augment_icons/vortex.png"),
}

#endregion

#region Private State

var _choices: Array = []
var _is_active: bool = false
var _selected_index: int = 1

# Pre-built card nodes (created in _ready, always in tree)
var _card_panels: Array[PanelContainer] = []
var _card_highlights: Array[TextureRect] = []
var _card_bgs: Array[TextureRect] = []
var _card_badges: Array[Label] = []
var _card_icons: Array[TextureRect] = []
var _card_names: Array[Label] = []
var _card_descs: Array[Label] = []

#endregion

#region Lifecycle

func _ready() -> void:
	visible = false

	# Debug: verify critical textures loaded on export
	if BG_COMMON == null:
		push_error("AugmentChoiceUI: BG_COMMON preload failed")
	if BG_RARE == null:
		push_error("AugmentChoiceUI: BG_RARE preload failed")
	if BG_MYTHICAL == null:
		push_error("AugmentChoiceUI: BG_MYTHICAL preload failed")
	if BG_HIGHLIGHT == null:
		push_error("AugmentChoiceUI: BG_HIGHLIGHT preload failed")

	_build_cards()
	Events.add_listener(AugmentSelectionStartedEvent, _on_selection_started)


func _build_cards() -> void:
	for i: int in range(CARD_COUNT):
		# Card panel — visible dark background as fallback if textures fail
		var panel := PanelContainer.new()
		panel.visible = false
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.gui_input.connect(_on_card_gui_input.bind(i))

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.12, 0.12, 0.95)
		style.set_corner_radius_all(8)
		panel.add_theme_stylebox_override("panel", style)

		# Background texture (covers the style fallback)
		var bg := TextureRect.new()
		bg.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(bg)
		_card_bgs.append(bg)

		# Highlight overlay
		var highlight := TextureRect.new()
		highlight.texture = BG_HIGHLIGHT
		highlight.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		highlight.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		highlight.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		highlight.visible = false
		panel.add_child(highlight)
		_card_highlights.append(highlight)

		# Badge label (child of bg for positioning)
		var badge := Label.new()
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		badge.add_theme_font_size_override("font_size", 20)
		if BOLD_FONT != null:
			badge.add_theme_font_override("font", BOLD_FONT)
		badge.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		badge.offset_left = 52
		badge.offset_top = 48
		badge.z_index = 10
		bg.add_child(badge)
		_card_badges.append(badge)

		# Content margin
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 45)
		margin.add_theme_constant_override("margin_right", 45)
		margin.add_theme_constant_override("margin_top", 20)
		margin.add_theme_constant_override("margin_bottom", 20)
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		vbox.size_flags_horizontal = Control.SIZE_FILL
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.add_child(vbox)

		# Icon
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(120, 120)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(icon)
		_card_icons.append(icon)

		var spacer1 := Control.new()
		spacer1.custom_minimum_size = Vector2(0, 20)
		vbox.add_child(spacer1)

		# Name
		var name_label := Label.new()
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		name_label.add_theme_font_size_override("font_size", 24)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(name_label)
		_card_names.append(name_label)

		var spacer2 := Control.new()
		spacer2.custom_minimum_size = Vector2(0, 12)
		vbox.add_child(spacer2)

		# Description
		var desc_label := Label.new()
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.add_theme_font_size_override("font_size", 16)
		desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		vbox.add_child(desc_label)
		_card_descs.append(desc_label)

		# Add to CanvasLayer in _ready — nodes exist before any pause
		add_child(panel)
		_card_panels.append(panel)


func _input(event: InputEvent) -> void:
	if not _is_active:
		return

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

func show_choices(choices: Array) -> void:
	_choices = choices
	_is_active = true

	var vp_size: Vector2 = get_viewport().get_visible_rect().size

	# Card layout from viewport
	var card_gap: float = vp_size.x * 0.012
	var card_w: float = (vp_size.x * 0.56 - card_gap * 2.0) / 3.0
	var card_h: float = card_w * 1.375
	var total_w: float = card_w * 3.0 + card_gap * 2.0
	var start_x: float = (vp_size.x - total_w) / 2.0
	var start_y: float = (vp_size.y - card_h) / 2.0

	for i: int in range(min(CARD_COUNT, choices.size())):
		var augment_data: AugmentData = choices[i] as AugmentData
		var card_x: float = start_x + i * (card_w + card_gap)

		var panel: PanelContainer = _card_panels[i]
		panel.position = Vector2(card_x, start_y)
		panel.size = Vector2(card_w, card_h)
		panel.visible = true

		_card_bgs[i].texture = _get_rarity_bg_texture(augment_data.rarity)
		_card_badges[i].text = AugmentManager.get_selection_label(augment_data)
		_card_names[i].text = augment_data.display_name
		_card_descs[i].text = augment_data.description
		_card_icons[i].texture = _get_icon_texture(augment_data.icon_key)

	# Hide unused cards
	for i: int in range(choices.size(), CARD_COUNT):
		_card_panels[i].visible = false

	visible = true
	_selected_index = clamp(1, 0, min(CARD_COUNT, choices.size()) - 1)
	_update_card_highlights()

	PauseEvent.invoke(true)


func hide_ui() -> void:
	_is_active = false
	for panel: PanelContainer in _card_panels:
		panel.visible = false
	visible = false
	PauseEvent.invoke(false)

#endregion

#region Private Methods

func _get_rarity_bg_texture(rarity: int) -> Texture2D:
	match rarity:
		Enums.AugmentRarity.MYTHICAL:
			return BG_MYTHICAL
		Enums.AugmentRarity.RARE:
			return BG_RARE
		_:
			return BG_COMMON


func _get_icon_texture(icon_key: String) -> Texture2D:
	if ICONS.has(icon_key):
		return ICONS[icon_key]
	push_error("AugmentChoiceUI: missing augment icon for key: %s" % icon_key)
	return null


func _select_card(index: int) -> void:
	var visible_count: int = 0
	for p: PanelContainer in _card_panels:
		if p.visible:
			visible_count += 1
	if index < 0 or index >= visible_count:
		return
	_selected_index = index
	_update_card_highlights()


func _update_card_highlights() -> void:
	for i: int in range(_card_panels.size()):
		if not _card_panels[i].visible:
			continue
		_card_highlights[i].visible = (i == _selected_index)


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

	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.CARD_SELECT)

	hide_ui()

	_trigger_augment_rescue()


func _trigger_augment_rescue() -> void:
	var balls := get_tree().get_nodes_in_group("ball")
	if balls.is_empty():
		return

	var ball: Node = balls[0]
	if ball.has_method("start_rescue_movement"):
		ball.start_rescue_movement(AUGMENT_ORB_TEXTURE)

#endregion

#region Event Handlers

func _on_selection_started(event: AugmentSelectionStartedEvent) -> void:
	show_choices(event._choices)

#endregion
