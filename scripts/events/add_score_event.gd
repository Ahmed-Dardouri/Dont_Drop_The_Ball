class_name AddScoreEvent extends Event

var _score: int

func _init(score: int) -> void:
	_score = score


static func invoke(score : int):
	Events.invoke(AddScoreEvent.new(score))
