extends Control

@onready var score_label: Label = $MarginContainer/score_label


var _score : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(AddScoreEvent, add_score_handler)
	update_score_label(_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_score_handler(event: AddScoreEvent):
	_score += event._score
	update_score_label(_score)

func update_score_label(score: int):
	score_label.text = str(score)
