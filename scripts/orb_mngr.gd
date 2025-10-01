extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(OrbCollectedEvent, orb_event_handler)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func orb_event_handler(event: OrbCollectedEvent):
	match event._props.Type:
		Enums.OrbType.BLUE:
			orb_event_handler_blue()
		Enums.OrbType.RED:
			orb_event_handler_red()
		_:
			orb_event_handler_red()
	pass


func orb_event_handler_blue():
	AddScoreEvent.invoke(Constants.orb_score_blue)
	pass
		
func orb_event_handler_red():
	AddScoreEvent.invoke(Constants.orb_score_red)
	pass
