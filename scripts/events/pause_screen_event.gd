class_name PauseScreenEvent extends Event


static func invoke():
	if PauseEvent.state == false:
		Events.invoke(PauseScreenEvent.new())
