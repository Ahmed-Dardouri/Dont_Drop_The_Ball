extends Node2D
class_name GenericOrb

#region orbs

@onready var blue_orb: BlueOrb = $child_orbs/blue_orb
@onready var red_orb: RedOrb = $child_orbs/red_orb
@onready var half_solid_orb: HalfSolidOrb = $child_orbs/half_solid_orb

#endregion

@onready var child_orbs: Node2D = $child_orbs

@onready var timer: Timer = $Timer

var _child_orb : Node2D
@export var _props : OrbProps = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_orb()
	init_timer()
	disable_child_orb()
func _process(delta: float) -> void:
	orb_spawn_animation()

func converge_orb(type: Enums.OrbType):
	match type:
		Enums.OrbType.BLUE:
			_child_orb = blue_orb
		Enums.OrbType.RED:
			_child_orb = red_orb
		Enums.OrbType.HALF_SOLID:
			_child_orb = half_solid_orb
		_: 
			_child_orb = null
		
	for child in child_orbs.get_children():
		if child != _child_orb:
			child.queue_free()
	 
			
func set_type(props :OrbProps):
	_props = props

func update_orb():
	converge_orb(_props.Type)

func set_child_opacity_to_timer():
	if _child_orb != null and timer != null:
		var value = float(float(timer.wait_time - timer.time_left)/timer.wait_time) * 0.75
		_child_orb.set_sprite_opacity(value)
	
func _on_timer_timeout() -> void:
	enable_child_orb()

	
func orb_spawn_animation():
	if timer.time_left != 0:
		set_child_opacity_to_timer()
	
func disable_child_orb():
	_child_orb.set_sprite_opacity(0)
	_child_orb.set_collision_enable(false)
	
	
func enable_child_orb():
	if _child_orb != null:
		_child_orb.set_sprite_opacity(1)
		_child_orb.set_collision_enable(true)

func init_timer():
	if timer != null:
		timer.one_shot = true
		timer.wait_time = 1.5
		timer.start()
