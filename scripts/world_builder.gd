extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldBuiltEvent.invoke()

func load_world():
	SoundPlayEvent.invoke(Enums.SoundType.MUSIC, Enums.Sounds.LOFI_BG_MUSIC)
