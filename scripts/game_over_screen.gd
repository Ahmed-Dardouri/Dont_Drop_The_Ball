extends Control

@onready var replay_btn: Button = $VBoxContainer/ReplayButton

func _ready() -> void:
	Events.add_listener(GameOverEvent, show_game_over)
	visible = false


func show_game_over(event: GameOverEvent) -> void:
	visible = true
	# Focus the button so keyboard/space activates it too
	replay_btn.grab_focus()

func replay() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()



func _on_replay_button_pressed() -> void:
	replay()
