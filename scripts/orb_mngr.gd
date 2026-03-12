extends Node2D
## Orb Manager - Listens to orb collection events.
## Scoring is now handled by ScoreBehavior in the OrbData system.
## This manager can be extended for achievements, statistics, etc.


func _ready() -> void:
	Events.add_listener(OrbCollectedEvent, _on_orb_collected)


func _on_orb_collected(event: OrbCollectedEvent) -> void:
	var orb_data: OrbData = event.get_orb_data()
	# Future: Add achievement tracking, statistics, etc.
	# For now, scoring is handled by ScoreBehavior in the orb's behaviors array.
	pass
