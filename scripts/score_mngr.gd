extends Control

@onready var score_label: Label = $MarginContainer/HBoxContainer/score_label
@onready var pb_label: Label = $MarginContainer/HBoxContainer/pb_label


var _score : int = 0
var _pb : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Listen to ScoreManager signal (new system)
	ScoreManager.score_changed.connect(_on_score_manager_changed)

	# Also listen to AddScoreEvent (legacy support)
	Events.add_listener(AddScoreEvent, add_score_handler)
	Events.add_listener(GameLoadEvent, pb_load_handler)

	# Initialize with current score
	_score = ScoreManager.get_score()
	update_score_label(_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_score_manager_changed(new_score: int) -> void:
	_score = new_score
	update_score_label(_score)


func add_score_handler(event: AddScoreEvent):
	_score += event._score
	update_score_label(_score)

func update_score_label(score: int):
	score_label.text = str(score)
	Variables.current_score = score

func update_pb_label(score: int):
	pb_label.text = str(score)

func pb_load_handler(event : GameLoadEvent):
	_pb = event._saved_game.pb
	update_pb_label(_pb)
	pass

func get_score() -> int :
	return _score
