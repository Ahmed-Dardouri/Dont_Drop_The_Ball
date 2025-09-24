extends Node2D
class_name GenericOrb
#region orb_sprites

@onready var blue_sprite: Sprite2D = $blue_sprite
@onready var red_sprite: Sprite2D = $red_sprite

#endregion

var _props : OrbProps = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_orb()


func orb_collected():
	OrbCollectedEvent.invoke_orb_event(_props.Type)
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
