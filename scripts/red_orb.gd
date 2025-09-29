extends Node2D
class_name RedOrb
@onready var orb_sprite: Sprite2D = $orb_sprite

@onready var timer: Timer = $Timer

var _props : OrbProps = null
var _lifespan : int = Constants.orb_lifespan_red

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_props_init()
	update_orb()


func orb_collected():
	OrbCollectedEvent.invoke_orb_event(_props)
	SoundPlayEvent.invoke_sound_play(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	orb_collected()


func update_orb():
	setup_timer()
	

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
	_props.Type = Enums.OrbType.RED
