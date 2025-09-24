extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(OrbCollectedEvent, orb_event_handler)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func orb_event_handler(event: OrbCollectedEvent):
	match event._type:
		Enums.OrbEvent.GENERIC:
			orb_event_handler_generic()
		Enums.OrbEvent.ADD_LIFE:
			orb_event_handler_add_life()
		_:
			orb_event_handler_add_life()
	pass


func orb_event_handler_generic():
	AddScoreEvent.invoke_add_score(Constants.orb_score_generic)
	pass
		
func orb_event_handler_add_life():
	AddScoreEvent.invoke_add_score(Constants.orb_score_add_life)
	pass
