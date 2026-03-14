extends Control


@export var move_power : int = 500

@onready var left_button: TouchScreenButton = $left_touch_button
@onready var right_button: TouchScreenButton = $right_touch_button
@onready var jump_button: TouchScreenButton = $jump_touch_button

# Button sizes (for positioning calculations)
const BUTTON_SIZE: Vector2 = Vector2(289, 230)  # Approximate size of touch buttons
const BUTTON_MARGIN: float = 20.0  # Margin from screen edges
const JUMP_BUTTON_HEIGHT: float = 500.0  # Height of jump area


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	load_constants()
	_position_buttons_for_screen()
	Events.add_listener(GameOverEvent, hide_controls)
	Events.add_listener(WorldBuiltEvent, handle_world_built)
	get_tree().get_root().size_changed.connect(_position_buttons_for_screen)


func _position_buttons_for_screen() -> void:
	if left_button == null or right_button == null or jump_button == null:
		return

	var screen_size: Vector2 = get_viewport().get_visible_rect().size

	# Position left button at bottom-left
	left_button.position = Vector2(
		BUTTON_MARGIN,
		screen_size.y - BUTTON_SIZE.y - BUTTON_MARGIN
	)

	# Position right button at bottom-right
	right_button.position = Vector2(
		screen_size.x - BUTTON_SIZE.x - BUTTON_MARGIN,
		screen_size.y - BUTTON_SIZE.y - BUTTON_MARGIN
	)

	# Position jump button to cover the entire top portion of screen
	# The jump button uses a large transparent texture with a rectangle shape
	# Position it to start from top-left and cover everything except bottom button area
	var jump_area_height: float = screen_size.y - BUTTON_SIZE.y - BUTTON_MARGIN * 2
	jump_button.position = Vector2(
		(screen_size.x - jump_button.scale.x * 570) / 2,  # Center horizontally (570 is shape width)
		max(0, jump_area_height - jump_button.scale.y * 500)  # Position to cover top area
	)


func _on_right_touch_button_pressed() -> void:
	var move := Enums.PlayerMoves.RIGHT 
	Events.invoke(MoveEvent.new(move, true, move_power))

func _on_right_touch_button_released() -> void:
	var move := Enums.PlayerMoves.RIGHT 
	Events.invoke(MoveEvent.new(move, false, move_power))

func _on_left_touch_button_pressed() -> void:
	var move := Enums.PlayerMoves.LEFT 
	Events.invoke(MoveEvent.new(move, true, move_power))

func _on_left_touch_button_released() -> void:
	var move := Enums.PlayerMoves.LEFT 
	Events.invoke(MoveEvent.new(move, false, move_power))

func _on_jump_touch_button_pressed() -> void:
	var move := Enums.PlayerMoves.JUMP 
	Events.invoke(MoveEvent.new(move, true, move_power))

func _on_jump_touch_button_released() -> void:
	var move := Enums.PlayerMoves.JUMP 
	Events.invoke(MoveEvent.new(move, false, move_power))
	

func handle_world_built(event: WorldBuiltEvent):
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		visible = true
	
func hide_controls(game_over_event: GameOverEvent):
	visible = false

func load_constants():
	move_power = Constants.player_keyboard_move_power
