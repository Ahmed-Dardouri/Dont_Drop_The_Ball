class_name OrbBehavior extends Resource
## Abstract base class for orb behaviors.
## Behaviors define what happens when an orb is collected or during its lifetime.
## Concrete behaviors extend this class and override methods as needed.

#region Properties

## Unique identifier for this behavior type
@export var behavior_id: String = ""

#endregion

#region Virtual Methods

## Called when orb is collected by the ball.
## Override in subclasses to implement collection behavior.
## context: { "orb": Orb, "orb_data": OrbData, "collector": Node }
func execute(_context: Dictionary) -> void:
	pass


## Called each physics frame while orb is active.
## Override in subclasses to implement movement or per-frame logic.
func process(_orb: Node, _delta: float) -> void:
	pass


## Called during spawn animation phase.
## Override in subclasses to customize spawn behavior.
func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
