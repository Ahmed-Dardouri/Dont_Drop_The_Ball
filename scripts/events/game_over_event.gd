class_name GameOverEvent extends Event

static func invoke():
	if PauseEvent.state == false:
		Events.invoke(GameOverEvent.new())
