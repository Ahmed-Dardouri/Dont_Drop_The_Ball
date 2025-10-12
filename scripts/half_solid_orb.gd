extends Node2D
class_name HalfSolidOrb
@onready var orb_sprite: Sprite2D = $orb_sprite

@onready var timer: Timer = $Timer

var _props : OrbProps = null
var _lifespan : int = Constants.orb_lifespan_half_solid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_props_init()
	update_orb()


func orb_collected():
	OrbCollectedEvent.invoke(_props)
	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
	queue_free()


func update_orb():
	setup_timer()
	rotation = randf_range(0.0, TAU)
	

func setup_timer():
	timer.one_shot = true
	timer.wait_time = _lifespan
	timer.autostart = true
	timer.timeout.connect(_on_timeout)
	timer.start()
	

func _on_timeout():
	queue_free()


func _props_init():
	_props = OrbProps.new()
	_props.Type = Enums.OrbType.HALF_SOLID


func _on_collect_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "ball":
		orb_collected()
