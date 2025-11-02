extends Node2D
class_name BlueOrb
@onready var orb_sprite: Sprite2D = $orb_sprite
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@onready var timer: Timer = $Timer

var _props : OrbProps = null
var _lifespan : int = Constants.orb_lifespan_blue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_props_init()
	update_orb()


func orb_collected():
	OrbCollectedEvent.invoke(_props)
	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "ball":
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
	_props.Type = Enums.OrbType.BLUE

func set_sprite_opacity(value : float):
	orb_sprite.modulate.a = value

func set_collision_enable(value: bool):
	collision_shape_2d.disabled = !value
