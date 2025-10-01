extends Node

const _SAVED_GAME_PATH := "user://savegame.tres"

var _saved_game : SavedGame = SavedGame.new()

func _ready() -> void:
	_init_saved_game()
	

func load_game():
	if ResourceLoader.exists(_SAVED_GAME_PATH):
		_saved_game = load(_SAVED_GAME_PATH)
	else:
		save_game()
	GameLoadEvent.invoke(_saved_game)
	

func set_saved_game(saved_game: SavedGame):
	_saved_game = saved_game

func get_saved_game() -> SavedGame:
	return _saved_game
	
func save_game():
	ResourceSaver.save(_saved_game, _SAVED_GAME_PATH)
	
func _init_saved_game():
	_saved_game.pb = 0
