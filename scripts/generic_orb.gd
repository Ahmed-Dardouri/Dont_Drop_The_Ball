extends Node2D
class_name GenericOrb

#region orbs

@onready var blue_orb: BlueOrb = $blue_orb
@onready var red_orb: RedOrb = $red_orb

#endregion


var _props : OrbProps = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_orb()


func converge_orb(type: Enums.OrbType):
	var orb
	match type:
		Enums.OrbType.BLUE:
			orb = blue_orb
		Enums.OrbType.RED:
			orb = red_orb
		_: orb = null
		
	for child in get_children():
		if child != orb:
			child.queue_free()
	 
			
func set_type(props :OrbProps):
	_props = props

func update_orb():
	converge_orb(_props.Type)
	
