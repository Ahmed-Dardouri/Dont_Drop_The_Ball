extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(OrbCollectedEvent, orb_event_handler)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func orb_event_handler(event: OrbCollectedEvent):
	match event._props.Type:
		Enums.OrbType.BLUE:
			orb_event_handler_blue()
		Enums.OrbType.RED:
			orb_event_handler_red()
		Enums.OrbType.HALF_SOLID:
			orb_event_handler_half_solid()
		_:
			pass


func orb_event_handler_blue():
	AddScoreEvent.invoke(Constants.orb_score_blue)
	
		
func orb_event_handler_red():
	AddScoreEvent.invoke(Constants.orb_score_red)
	

func orb_event_handler_half_solid():
	AddScoreEvent.invoke(Constants.orb_score_half_solid)
	
