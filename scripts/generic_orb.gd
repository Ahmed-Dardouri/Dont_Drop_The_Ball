extends Node2D
class_name GenericOrb
#region orb_sprites

@onready var blue_sprite: Sprite2D = $blue_sprite
@onready var red_sprite: Sprite2D = $red_sprite

#endregion
@onready var timer: Timer = $Timer

var _props : OrbProps = null
var _lifespan : int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_orb()


func orb_collected():
	OrbCollectedEvent.invoke_orb_event(_props.Type)
	SoundPlayEvent.invoke_sound_play(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
	queue_free()



func _on_area_2d_body_entered(body: Node2D) -> void:
	orb_collected()


func select_sprite(type: int):
	match type:
		Enums.OrbEvent.GENERIC:
			blue_sprite.visible = true
		Enums.OrbEvent.ADD_LIFE:
			red_sprite.visible = true
		_:
			blue_sprite.visible = true


func set_type(props :OrbProps):
	_props = props

func update_orb():
	select_sprite(_props.Type)
	set_lifespan() # must set life span before timer
	setup_timer()
	
func set_lifespan():
	match _props.Type:
		Enums.OrbEvent.GENERIC:
			_lifespan = Constants.orb_lifespan_generic
		Enums.OrbEvent.ADD_LIFE:
			_lifespan = Constants.orb_lifespan_add_life
		_: 
			_lifespan = 1



func setup_timer():
	timer.one_shot = true
	timer.wait_time = _lifespan
	timer.autostart = true
	timer.timeout.connect(_on_timeout)
	timer.start()
	

func _on_timeout():
	queue_free()
