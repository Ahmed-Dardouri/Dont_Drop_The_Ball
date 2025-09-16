extends Control


@export var move_power : int = 600


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(GameOverEvent, hide_controls)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_right_touch_button_pressed() -> void:
	var move := PlayerMoves.RIGHT 
	Events.invoke(MoveEvent.new(move, true, move_power))

func _on_right_touch_button_released() -> void:
	var move := PlayerMoves.RIGHT 
	Events.invoke(MoveEvent.new(move, false, move_power))

func _on_left_touch_button_pressed() -> void:
	var move := PlayerMoves.LEFT 
	Events.invoke(MoveEvent.new(move, true, move_power))

func _on_left_touch_button_released() -> void:
	var move := PlayerMoves.LEFT 
	Events.invoke(MoveEvent.new(move, false, move_power))

func _on_jump_touch_button_pressed() -> void:
	var move := PlayerMoves.JUMP 
	Events.invoke(MoveEvent.new(move, true, move_power))

func _on_jump_touch_button_released() -> void:
	var move := PlayerMoves.JUMP 
	Events.invoke(MoveEvent.new(move, false, move_power))
	
	
	
func hide_controls(game_over_event: GameOverEvent):
	visible = false
