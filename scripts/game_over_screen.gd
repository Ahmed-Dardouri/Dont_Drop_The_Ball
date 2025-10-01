extends Control

@onready var replay_btn: Button = $VBoxContainer/ReplayButton
@onready var score_mngr: Control = $"../score_mngr"


func _ready() -> void:
	Events.add_listener(GameOverEvent, handle_game_over)
	visible = false


func handle_game_over(event: GameOverEvent) -> void:
	var saved_game := GameSaveMngr.get_saved_game()
	var curr_score = get_current_score()
	saved_game.pb = max(curr_score, saved_game.pb)
	GameSaveMngr.set_saved_game(saved_game)
	GameSaveMngr.save_game()
	visible = true
	# Focus the button so keyboard/space activates it too
	replay_btn.grab_focus()

func replay() -> void:
	ReplayEvent.invoke()



func _on_replay_button_pressed() -> void:
	replay()

func get_current_score() -> int :
	return score_mngr.get_score()
