class_name GameOverEvent extends Event

static func invoke_game_over():
	Events.invoke(GameOverEvent.new())
