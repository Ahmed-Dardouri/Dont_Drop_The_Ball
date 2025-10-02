class_name AddScoreEvent extends Event

var _score: int

func _init(score: int) -> void:
	_score = score


static func invoke(score : int):
	if PauseEvent.state == false:
		Events.invoke(AddScoreEvent.new(score))
