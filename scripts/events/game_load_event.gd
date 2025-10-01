class_name GameLoadEvent extends Event

var _saved_game : SavedGame

func _init(saved_game: SavedGame) -> void:
	_saved_game = saved_game

static func invoke(saved_game : SavedGame):
	Events.invoke(GameLoadEvent.new(saved_game))
